#include <windows.h>
#include <string>
#include <iostream>

std::string ExePath() {
	char buffer[MAX_PATH];
	GetModuleFileName(NULL, buffer, MAX_PATH);
	std::string::size_type pos = std::string(buffer).find_last_of("\\/");
	return std::string(buffer).substr(0, pos);
}

bool startup(LPCTSTR lpApplicationName, char *argv[])
{
	bool result = false;
	// additional information
	STARTUPINFO si;
	PROCESS_INFORMATION pi;

	// set the size of the structures
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));

	// start the program up
	result = CreateProcess(lpApplicationName,   // the path
		argv[1],        // Command line
		NULL,           // Process handle not inheritable
		NULL,           // Thread handle not inheritable
		FALSE,          // Set handle inheritance to FALSE
		0,              // No creation flags
		NULL,           // Use parent's environment block
		NULL,           // Use parent's starting directory 
		&si,            // Pointer to STARTUPINFO structure
		&pi             // Pointer to PROCESS_INFORMATION structure (removed extra parentheses)
	);
	// Close process and thread handles. 
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
	return result;
}


int main(int argc, char *argv[])
{
	std::string currentFolder = ExePath();
	std::cout << "Current folder 001: " << currentFolder << std::endl;

	currentFolder += "\\bin";

	bool changeResult = SetCurrentDirectory(currentFolder.c_str());
	std::cout << "Current folder 002: " << currentFolder << std::endl;

	std::cout << "Error changing cwd ¿?: " << changeResult << std::endl;

	//currentFolder += "\\bittube-wallet-gui.exe";
	currentFolder += "\\start-low-graphics-mode.bat";
	
	
	bool result = startup(currentFolder.c_str(), argv);
	std::cout << "Current folder 003: " << currentFolder << std::endl;

	std::cout << "Error launch bin ¿?: " << result << std::endl;
	
	//----
	int number;
	
	std::cout << "my directory is " << ExePath() << std::endl;

	std::cout << "hola" << std::endl;

	std::cin >> number;


	return 0;
}