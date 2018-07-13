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


int main(int argc, char *argv[]) {

	std::string currentFolder = ExePath();
	currentFolder += "\\bin";

	std::cout << "   - Changing current working directory to: " << currentFolder << std::endl;
	bool changeResult = SetCurrentDirectory(currentFolder.c_str());
	std::cout << "      - Result: ";

	if (!changeResult) {
		std::cout << "Changed fail" << std::endl;
		//TODO: error handling
	}
	else {
		std::cout << "Changed ok" << std::endl;

#ifdef LOWRESBIN
		currentFolder += "\\start-low-graphics-mode.bat";
#else
		currentFolder += "\\bittube-wallet-gui.exe";
#endif
		std::cout << "   - Launching wallet: " << currentFolder << std::endl;
		bool launchResult = startup(currentFolder.c_str(), argv);
		std::cout << "      - Result: ";

		if (!launchResult) {
			std::cout << "Launched fail" << std::endl;
			//TODO: error handling
		}
		else {
			std::cout << "Launched ok" << std::endl;
		}
	}

	std::cout << std::endl << "Press any key to finish...";
	std::cin.get();

	return 0;
}