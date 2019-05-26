/**
 * @file
 * fileMap.cuh
 *
 * @brief files mmap support
 */

#pragma once

#include <string>

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define MAP_ON_GPU      0x80000

//using namespace std;

template<class Type>
struct fileMapping
{
	std::string filename;
	int fd;
	long	map_start;
	long	map_len;
	Type 	*addr;	//addr returned by mmap

	fileMapping() {
		fd = -1;
		map_start = 0;
		map_len = 0;
		addr = NULL;
	}

	fileMapping(std::string filename, long size = 0, long offset = 0, bool ON_GPU=false) {
		struct stat sb;
		printf("fileMapping: constructor enter. file = %s \n", filename.c_str());
		//this->filename.assign(filename);
		//Open file and save pointer
		fd = open(filename.c_str(), O_RDWR);
        if (fd == -1) {
        	printf("fileMapping: Erro opening file\n");
            return;
        }
		if (fstat(fd, &sb) == -1) {          /* To obtain file size */
            //cout << "Erro fstat" <<endl;
			close(fd);
			return;
		}
		if (!size)
			size = sb.st_size;
		int flags = /*MAP_NORESERVE |*/ MAP_SHARED ;
		if (ON_GPU)
			flags |= MAP_ON_GPU;
		printf("fileMapping: mapping size %ld file size %ld offset %ld ON_GPU=%d\n", size,  sb.st_size, offset,ON_GPU );
		addr = (Type *)mmap(NULL, size,  PROT_READ | PROT_WRITE, flags, fd, offset);
		map_len = size;
		if (addr == MAP_FAILED) {
			//cout << "ERROR mapping file" << endl;
			close(fd);
			return ;
		}
	}

	int map(std::string filename, long size = 0, long offset = 0, bool ON_GPU=false) {
		struct stat sb;
		printf("fileMapping: mmap enter. file = %s \n", filename.c_str());
		//this->filename.assign(filename);
		//Open file and save pointer
		fd = open(filename.c_str(), O_RDONLY);
		if (fd == -1) {
			printf("fileMapping: Erro opening file\n");
			return -1;
		}
		if (fstat(fd, &sb) == -1) {          /* To obtain file size */
			//cout << "Erro fstat" <<endl;
			close(fd);
			return -1;
		}
		if (!size) {
			size = sb.st_size;
		}
		int flags = MAP_NORESERVE | MAP_SHARED ;
		if (ON_GPU)
				flags |= MAP_ON_GPU;
		printf("fileMapping: map: mapping size %ld file size %ld offset %ld ON_GPU=%d\n", size,  sb.st_size, offset, ON_GPU );
		addr = (Type *)mmap(NULL, size,  PROT_READ, flags, fd, offset);
		map_len = size;
		if (addr == MAP_FAILED) {
			//cout << "ERROR mapping file" << endl;
			close(fd);
			return -1;
		}
		return 0;
	}

	void sync() {
		msync(addr, map_len, MS_SYNC);
	}

	Type *get_addr(void) {
		return addr;
	}

	~fileMapping(void) {
		//unmap && close the mmaped file
		printf("~fileMapping: closing&unmapping file %s\n", filename.c_str());
		munmap(addr, map_len);
		close(fd);
	}

};


// Leave this at the end of the file
// Local Variables:
// mode:c++
// c-file-style: "NVIDIA"
// End:
