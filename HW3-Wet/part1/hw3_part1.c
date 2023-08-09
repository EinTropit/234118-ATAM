#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <signal.h>
#include <syscall.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/reg.h>
#include <sys/user.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdbool.h>

#include "elf64.h"

#define	ET_NONE	0	//No file type 
#define	ET_REL	1	//Relocatable file 
#define	ET_EXEC	2	//Executable file 
#define	ET_DYN	3	//Shared object file 
#define	ET_CORE	4	//Core file 

#define SHT_SYMTAB 2
#define SHT_STRTAB 3
#define STB_GLOBAL 1
#define GENERAL_FAIL -5

size_t fpread(void *buffer, size_t size, size_t mitems, size_t offset, FILE *fp)
{
     if (fseek(fp, offset, SEEK_SET) != 0)
         return 0;
     return fread(buffer, size, mitems, fp);
}

/* symbol_name		- The symbol (maybe function) we need to search for.
 * exe_file_name	- The file where we search the symbol in.
 * error_val		- If  1: A global symbol was found, and defined in the given executable.
 * 			- If -1: Symbol not found.
 *			- If -2: Only a local symbol was found.
 * 			- If -3: File is not an executable.
 * 			- If -4: The symbol was found, it is global, but it is not defined in the executable.
 * return value		- The address which the symbol_name will be loaded to, if the symbol was found and is global.
 */
unsigned long find_symbol(char* symbol_name, char* exe_file_name, int* error_val) {
	
	Elf64_Ehdr ELFHeader;
	FILE* elfFile = fopen(exe_file_name, "r");
	
	if(!elfFile)
	{
		*error_val = GENERAL_FAIL;
		return 0;
	}

	fread(&ELFHeader, sizeof(Elf64_Ehdr), 1, elfFile);

	if(ELFHeader.e_type != ET_EXEC)
	{
		fclose(elfFile);
		*error_val = -3;
		return 0;
	}

	char *buffer = (char*)malloc(sizeof(char) * 8);
	int shdr_Amount = ELFHeader.e_shnum;
	int symtab_idx = -1, strtab_idx = -1;
	Elf64_Shdr *sectionHeaders = (Elf64_Shdr*) malloc(sizeof(Elf64_Shdr) * shdr_Amount);
	Elf64_Shdr shstrtab;
	fpread(sectionHeaders, sizeof(Elf64_Shdr), shdr_Amount, ELFHeader.e_shoff, elfFile);
	for(int i = 0; i < shdr_Amount; i++)
	{
		fpread(buffer ,sizeof(char) , 8, sectionHeaders[ELFHeader.e_shstrndx].sh_offset + sectionHeaders[i].sh_name, elfFile);
		if(strcmp(buffer, ".symtab") == 0)
			symtab_idx = i;
		else if(strcmp(buffer, ".strtab") == 0)
			strtab_idx = i;
	}
	if(strtab_idx == -1 || symtab_idx == -1)
	{
		fclose(elfFile);
		*error_val = GENERAL_FAIL;
		return 0;
	}
	free(buffer);
	Elf64_Shdr symtab = sectionHeaders[symtab_idx];
	Elf64_Shdr strtab = sectionHeaders[strtab_idx];
	free(sectionHeaders);
	int symtab_entry_amount = symtab.sh_size / symtab.sh_entsize;

	int found = 0;
	Elf64_Sym symbol_entry;
	buffer = (char*)malloc(sizeof(char) * (strlen(symbol_name) + 1));
	for(int i = 0; i < symtab_entry_amount; i++)
	{
		fpread(&symbol_entry, sizeof(Elf64_Sym), 1, symtab.sh_offset + i * sizeof(Elf64_Sym), elfFile);
		fpread(buffer ,sizeof(char) , strlen(symbol_name) + 1, strtab.sh_offset + symbol_entry.st_name, elfFile);
		if(strcmp(symbol_name, buffer) == 0)
		{
			found = 1;
			if(ELF64_ST_BIND(symbol_entry.st_info) == STB_GLOBAL)
			{
				found = 2;
				if(symbol_entry.st_shndx != SHN_UNDEF)
				{
					found = 3;
					break;
				}
			}
		}
	} 
	free(buffer);

	if(found == 0)
	{
		fclose(elfFile);
		*error_val = -1;
		return 0;
	}
	else if(found == 1)
	{
		fclose(elfFile);
		*error_val = -2;
		return 0;
	}
	else if(found == 2)
	{
		fclose(elfFile);
		*error_val = -4;
		return 0;
	}


	*error_val = 1;
	fclose(elfFile);
	return symbol_entry.st_value;
}

int main(int argc, char *const argv[]) {
	int err = 0;
	unsigned long addr = find_symbol(argv[1], argv[2], &err);

	if (addr > 0)
		printf("%s will be loaded to 0x%lx\n", argv[1], addr);
	else if (err == -2)
		printf("%s is not a global symbol! :(\n", argv[1]);
	else if (err == -1)
		printf("%s not found!\n", argv[1]);
	else if (err == -3)
		printf("%s not an executable! :(\n", argv[2]);
	else if (err == -4)
		printf("%s is a global symbol, but will come from a shared library\n", argv[1]);
	return 0;
}