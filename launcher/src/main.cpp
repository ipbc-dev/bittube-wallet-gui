#include <windows.h>
#include <string>
#include <iostream>

/*
 * Description: Get .exe folder path
 */
std::string ExePath() {
	char buffer[MAX_PATH];
	GetModuleFileName(NULL, buffer, MAX_PATH);
	std::string::size_type pos = std::string(buffer).find_last_of("\\/");
	return std::string(buffer).substr(0, pos);
}

/*
 * Description: Launch external .exe
 */
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

/*
 * Description: Waiting user key press to exit (console)
 */
void exitPause() {
	std::cout << std::endl << "Press any key to finish...";
	std::cin.get();

	exit(EXIT_FAILURE);
}


int main(int argc, char *argv[]) {

	std::string currentFolder = ExePath();
	currentFolder += "\\bin";

	bool changeResult = SetCurrentDirectory(currentFolder.c_str());

	if (!changeResult) {
		std::cout << "   - Changing current working directory to: " << currentFolder << std::endl;
		std::cout << "   - Status: ERROR! - Changed fail" << std::endl;
		exitPause();
	}
	else {

#ifdef LOWRESBIN
		currentFolder += "\\start-low-graphics-mode.bat";
#else
		currentFolder += "\\bittube-wallet-gui.exe";
#endif

		bool launchResult = startup(currentFolder.c_str(), argv);

		if (!launchResult) {
			std::cout << "   - Launching wallet: " << currentFolder << std::endl;
			std::cout << "   - Status: ERROR! - Launched fail" << std::endl;
			exitPause();
		}
	}

	return 0;
}