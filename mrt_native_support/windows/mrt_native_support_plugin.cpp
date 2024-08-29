#include "mrt_native_support_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <sstream>
#include <Shlobj.h>

namespace mrt_native_support
{
	bool IsWindows11OrGreater()
	{
		DWORD dwVersion = 0;
		DWORD dwBuild = 0;

#pragma warning(push)
#pragma warning(disable : 4996)
		dwVersion = GetVersion();
		// Get the build number.
		if (dwVersion < 0x80000000)
			dwBuild = (DWORD)(HIWORD(dwVersion));
#pragma warning(pop)

		return dwBuild < 22000;
	}
	const flutter::EncodableValue *ValueOrNull(const flutter::EncodableMap &map,
											   const char *key)
	{
		auto it = map.find(flutter::EncodableValue(key));
		if (it == map.end())
		{
			return nullptr;
		}
		return &(it->second);
	}

	// static
	void MrtNativeSupport::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows *registrar)
	{
		auto channel =
			std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
				registrar->messenger(), "com.metnetwork.mrt_n.methodChannel",
				&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<MrtNativeSupport>(registrar);

		channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto &call, auto result)
			{
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		registrar->AddPlugin(std::move(plugin));
	}

	MrtNativeSupport::MrtNativeSupport(flutter::PluginRegistrarWindows *registrar) : registrar(registrar)
	{
		channel_ =
			std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(registrar->messenger(),
																			  "com.metnetwork.mrt_n.methodChannel",
																			  &flutter::StandardMethodCodec::GetInstance());

		window_proc_id = registrar->RegisterTopLevelWindowProcDelegate(
			[this](HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
			{
				return HandleWindowProc(hWnd, message, wParam, lParam);
			});
	}

	MrtNativeSupport::~MrtNativeSupport() {}

	const std::string ELEMENT_PREFERENCES_KEY_PREFIX = SECURE_STORAGE_KEY_PREFIX;
	const int ELEMENT_PREFERENCES_KEY_PREFIX_LENGTH = (sizeof SECURE_STORAGE_KEY_PREFIX) - 1;

	// this string is used to filter the credential storage so that only the values written
	// by this plugin shows up.
	const CA2W CREDENTIAL_FILTER((ELEMENT_PREFERENCES_KEY_PREFIX + '*').c_str());

	static inline void rtrim(std::wstring &s)
	{
		s.erase(std::find_if(s.rbegin(), s.rend(), [](wchar_t ch)
							 { return !std::isspace(ch); })
					.base(),
				s.end());
	}

	std::optional<std::string> MrtNativeSupport::GetValueKey(const flutter::EncodableMap *args)
	{
		auto key = this->GetStringArg("key", args);
		if (key.has_value())
			return ELEMENT_PREFERENCES_KEY_PREFIX + key.value();
		return std::nullopt;
	}
	std::string MrtNativeSupport::RemoveKeyPrefix(const std::string &key)
	{
		return key.substr(ELEMENT_PREFERENCES_KEY_PREFIX_LENGTH);
	}
	std::optional<std::string> MrtNativeSupport::GetStringArg(
		const std::string &param,
		const flutter::EncodableMap *args)
	{
		auto p = args->find(param);
		if (p == args->end())
			return std::nullopt;
		return std::get<std::string>(p->second);
	}
	std::optional<std::vector<std::string>> MrtNativeSupport::GetStringListArg(
		const std::string &key,
		const flutter::EncodableMap *args)
	{
		// Find the key in the EncodableMap
		auto it = args->find(flutter::EncodableValue(key));
		if (it == args->end())
		{
			// Key not found, return std::nullopt
			return std::nullopt;
		}

		// Try to extract the value as a vector of strings
		if (const std::vector<flutter::EncodableValue> *list = std::get_if<std::vector<flutter::EncodableValue>>(&(it->second)))
		{
			std::vector<std::string> result;
			result.reserve(list->size());

			// Convert EncodableValue to std::string
			for (const auto &value : *list)
			{
				if (const std::string *str = std::get_if<std::string>(&value))
				{
					result.push_back(*str);
				}
			}
			return result;
		}

		// The value is not a list of strings, return std::nullopt
		return std::nullopt;
	}
	std::optional<std::vector<std::string>> MrtNativeSupport::GetListValueKey(const flutter::EncodableMap *args)
	{
		// Retrieve the list of strings using the key "key"
		auto list = this->GetStringListArg("keys", args);
		if (list.has_value())
		{
			// If the list is found, return it prefixed by ELEMENT_PREFERENCES_KEY_PREFIX
			std::vector<std::string> prefixedList;
			prefixedList.reserve(list->size());

			for (const std::string &value : list.value())
			{
				prefixedList.push_back(ELEMENT_PREFERENCES_KEY_PREFIX + value);
			}

			return prefixedList;
		}

		// If not found, return std::nullopt
		return std::nullopt;
	}
	std::optional<std::string> MrtNativeSupport::GetStringArgOrEmpty(
		const std::string &param,
		const flutter::EncodableMap *args)
	{

		auto p = args->find(param);
		if (p == args->end() || p->second.IsNull())
		{
			// Return empty string if the parameter is not present or is null
			return "";
		}

		// Check if the parameter is a string
		if (auto value = std::get_if<std::string>(&p->second))
		{
			return *value;
		}
		else
		{
			// Return empty string if the parameter is not a string
			return "";
		}
	}

	std::string MrtNativeSupport::GetErrorString(const DWORD &error_code)
	{
		switch (error_code)
		{
		case ERROR_NO_SUCH_LOGON_SESSION:
			return "ERROR_NO_SUCH_LOGIN_SESSION";
		case ERROR_INVALID_FLAGS:
			return "ERROR_INVALID_FLAGS";
		case ERROR_BAD_USERNAME:
			return "ERROR_BAD_USERNAME";
		case SCARD_E_NO_READERS_AVAILABLE:
			return "SCARD_E_NO_READERS_AVAILABLE";
		case SCARD_E_NO_SMARTCARD:
			return "SCARD_E_NO_SMARTCARD";
		case SCARD_W_REMOVED_CARD:
			return "SCARD_W_REMOVED_CARD";
		case SCARD_W_WRONG_CHV:
			return "SCARD_W_WRONG_CHV";
		case ERROR_INVALID_PARAMETER:
			return "ERROR_INVALID_PARAMETER";
		default:
			return "UNKNOWN_ERROR";
		}
	}

	std::string MrtNativeSupport::NtStatusToString(const CHAR *operation, NTSTATUS status)
	{
		std::ostringstream oss;
		oss << operation << ", 0x" << std::hex << status;

		switch (status)
		{
		case 0xc0000000:
			oss << " (STATUS_SUCCESS)";
			break;
		case 0xC0000008:
			oss << " (STATUS_INVALID_HANDLE)";
			break;
		case 0xc000000d:
			oss << " (STATUS_INVALID_PARAMETER)";
			break;
		case 0xc00000bb:
			oss << " (STATUS_NOT_SUPPORTED)";
			break;
		case 0xC0000225:
			oss << " (STATUS_NOT_FOUND)";
			break;
		}
		return oss.str();
	}

	DWORD MrtNativeSupport::GetApplicationSupportPath(std::wstring &path)
	{
		std::wstring companyName;
		std::wstring productName;
		TCHAR nameBuffer[MAX_PATH + 1]{};
		char *infoBuffer;
		DWORD versionInfoSize;
		DWORD resVal;
		UINT queryLen;
		LPVOID queryVal;
		LPWSTR appdataPath;
		std::wostringstream stream;

		SHGetKnownFolderPath(FOLDERID_RoamingAppData, KF_FLAG_DEFAULT, NULL, &appdataPath);

		if (nameBuffer == NULL)
		{
			return ERROR_OUTOFMEMORY;
		}

		resVal = GetModuleFileName(NULL, nameBuffer, MAX_PATH);
		if (resVal == 0)
		{
			return GetLastError();
		}

		versionInfoSize = GetFileVersionInfoSize(nameBuffer, NULL);
		if (versionInfoSize != 0)
		{
			infoBuffer = (char *)calloc(versionInfoSize, sizeof(char));
			if (infoBuffer == NULL)
			{
				return ERROR_OUTOFMEMORY;
			}
			if (GetFileVersionInfo(nameBuffer, 0, versionInfoSize, infoBuffer) == 0)
			{
				free(infoBuffer);
				infoBuffer = NULL;
			}
			else
			{

				if (VerQueryValue(infoBuffer, TEXT("\\StringFileInfo\\040904e4\\CompanyName"), &queryVal, &queryLen) != 0)
				{
					companyName = SanitizeDirString(std::wstring((const TCHAR *)queryVal));
				}
				if (VerQueryValue(infoBuffer, TEXT("\\StringFileInfo\\040904e4\\ProductName"), &queryVal, &queryLen) != 0)
				{
					productName = SanitizeDirString(std::wstring((const TCHAR *)queryVal));
				}
			}
			stream << appdataPath << "\\" << companyName << "\\" << productName;
			path = stream.str();
		}
		else
		{
			return GetLastError();
		}
		return ERROR_SUCCESS;
	}

	std::wstring MrtNativeSupport::SanitizeDirString(std::wstring string)
	{
		std::wstring sanitizedString = std::regex_replace(string, std::wregex(L"[<>:\"/\\\\|?*]"), L"_");
		rtrim(sanitizedString);
		sanitizedString = std::regex_replace(sanitizedString, std::wregex(L"[.]+$"), L"");
		return sanitizedString;
	}

	bool MrtNativeSupport::PathExists(const std::wstring &path)
	{
		struct _stat info;
		if (_wstat(path.c_str(), &info) != 0)
		{
			return false;
		}
		return (info.st_mode & _S_IFDIR) != 0;
	}

	bool MrtNativeSupport::MakePath(const std::wstring &path)
	{
		int ret = _wmkdir(path.c_str());
		if (ret == 0)
		{
			return true;
		}
		switch (errno)
		{
		case ENOENT:
		{
			size_t pos = path.find_last_of('/');
			if (pos == std::wstring::npos)
				pos = path.find_last_of('\\');
			if (pos == std::wstring::npos)
				return false;
			if (!MakePath(path.substr(0, pos)))
				return false;
		}
			return 0 == _wmkdir(path.c_str());
		case EEXIST:
			return PathExists(path);
		default:
			return false;
		}
	}

	PBYTE MrtNativeSupport::GetEncryptionKey()
	{
		const size_t KEY_SIZE = 16;
		DWORD credError = 0;
		PBYTE AesKey;
		PCREDENTIALW pcred;
		CA2W target_name(("key_" + ELEMENT_PREFERENCES_KEY_PREFIX).c_str());

		AesKey = (PBYTE)HeapAlloc(GetProcessHeap(), 0, KEY_SIZE);
		if (NULL == AesKey)
		{
			return NULL;
		}

		bool ok = CredReadW(target_name.m_psz, CRED_TYPE_GENERIC, 0, &pcred);
		if (ok)
		{
			if (pcred->CredentialBlobSize != KEY_SIZE)
			{
				CredFree(pcred);
				CredDeleteW(target_name.m_psz, CRED_TYPE_GENERIC, 0);
				goto NewKey;
			}
			memcpy(AesKey, pcred->CredentialBlob, KEY_SIZE);
			CredFree(pcred);
			return AesKey;
		}
		credError = GetLastError();
		if (credError != ERROR_NOT_FOUND)
		{
			return NULL;
		}
	NewKey:
		if (BCryptGenRandom(NULL, AesKey, KEY_SIZE, BCRYPT_USE_SYSTEM_PREFERRED_RNG) != ERROR_SUCCESS)
		{
			return NULL;
		}
		CREDENTIALW cred = {0};
		cred.Type = CRED_TYPE_GENERIC;
		cred.TargetName = target_name.m_psz;
		cred.CredentialBlobSize = KEY_SIZE;
		cred.CredentialBlob = AesKey;
		cred.Persist = CRED_PERSIST_LOCAL_MACHINE;

		ok = CredWriteW(&cred, 0);
		if (!ok)
		{
			std::cerr << "Failed to write encryption key" << std::endl;
			return NULL;
		}
		return AesKey;
	}

	void MrtNativeSupport::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue> &method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		auto method = method_call.method_name();
		const auto *args = std::get_if<flutter::EncodableMap>(method_call.arguments());
		std::wstring path;
		if (GetApplicationSupportPath(path) != ERROR_SUCCESS)
		{
			result->Error("Exception occurred", "GetApplicationSupportPath");
			return;
		}
		try
		{
			if (method == "secureStorage")
			{
				auto methodType = this->GetStringArg("type", args);
				if (methodType == "write")
				{
					auto key = this->GetValueKey(args);
					auto val = this->GetStringArg("value", args);
					if (key.has_value())
					{
						if (val.has_value())
							this->Write(key.value(), val.value());
						else
							this->Delete(key.value());
						result->Success(true);
					}
					else
					{
						result->Error("Exception occurred", "write");
					}
				}
				else if (methodType == "readMultiple")
				{
					auto keys = this->GetListValueKey(args);
					flutter::EncodableMap creds;
					if (keys.has_value())
					{

						// Iterate through each key in the list and attempt to delete
						for (const auto &key : keys.value())
						{
							auto val = this->Read(key);
							if (val.has_value())
							{
								std::string correctKey = this->RemoveKeyPrefix(key);
								creds[correctKey] = val.value();
							}
						}

						result->Success(creds);
					}
					else
					{
						result->Error("Exception occurred", "write");
					}
				}
				else if (methodType == "read")
				{
					auto key = this->GetValueKey(args);
					if (key.has_value())
					{
						auto val = this->Read(key.value());
						if (val.has_value())
							result->Success(flutter::EncodableValue(val.value()));
						else
							result->Success();
					}
					else
					{
						result->Error("Exception occurred", "read");
					}
				}
				else if (methodType == "readAll")
				{
					auto creds = this->ReadAll();
					result->Success(flutter::EncodableValue(creds));
				}
				else if (methodType == "remove")
				{
					auto key = this->GetValueKey(args);
					if (key.has_value())
					{
						this->Delete(key.value());
						result->Success(true);
					}
					else
					{
						result->Success(false);
					}
				}
				else if (methodType == "removeMultiple")
				{
					auto keys = this->GetListValueKey(args);
					if (keys.has_value() && !keys->empty())
					{

						// Iterate through each key in the list and attempt to delete
						for (const auto &key : keys.value())
						{
							this->Delete(key);
						}

						// Return true if all keys were successfully deleted, otherwise false
						result->Success(true);
					}
					else
					{
						result->Success(false);
					}
				}
				else if (methodType == "removeAll")
				{
					this->DeleteAll();
					result->Success(true);
				}
				else if (methodType == "containsKey")
				{
					auto key = this->GetValueKey(args);
					if (key.has_value())
					{
						auto contains_key = this->ContainsKey(key.value());
						result->Success(flutter::EncodableValue(contains_key));
					}
					else
					{
						result->Error("Exception occurred", "containsKey");
					}
				}
				else
				{
					result->NotImplemented();
				}
			}
			else if (method == "lunch_uri")
			{
				auto val = this->GetStringArg("uri", args);
				if (val.has_value())
				{
					result->Success(LaunchUrl(val.value()));
				}
				else
				{
					result->Success(false);
				}
			}
			else if (method == "path")
			{
				auto paths = this->getPaths();
				result->Success(flutter::EncodableValue(paths));
			}
			else if (method == "windowsManager")
			{
				auto methodType = this->GetStringArg("type", args);
				if (methodType == "show")
				{
					Show();
					result->Success(true);
				}
				else if (methodType == "hide")
				{
					Hide();
					result->Success(true);
				}
				else if (methodType == "init")
				{
					Init();
					result->Success(true);
				}
				else if (methodType == "setbounds")
				{
					const flutter::EncodableMap &argsRef = *args;
					SetBounds(argsRef);
					result->Success(true);
				}
				else if (methodType == "isFullScreen")
				{
					result->Success(IsFullScreen());
				}
				else if (methodType == "setFullScreen")
				{
					const flutter::EncodableMap &argsRef = *args;
					SetFullScreen(argsRef);
					result->Success(true);
				}
				else if (methodType == "maximumSize")
				{
					const flutter::EncodableMap &argsRef = *args;
					result->Success(SetMaximumSize(argsRef));
				}
				else if (methodType == "minimumSize")
				{
					const flutter::EncodableMap &argsRef = *args;
					result->Success(SetMinimumSize(argsRef));
				}
				else if (methodType == "isMaximized")
				{
					result->Success(IsMaximized());
				}
				else if (methodType == "isMinimized")
				{
					result->Success(IsMinimized());
				}
				else if (methodType == "restore")
				{
					Restore();
					result->Success(true);
				}
				else if (methodType == "unmaximize")
				{
					Unmaximize();
					result->Success(true);
				}
				else if (methodType == "waitUntilReadyToShow")
				{
					WaitUntilReadyToShow();
					result->Success(true);
				}
				else if (methodType == "isVisible")
				{
					result->Success(IsVisible());
				}
				else if (methodType == "isFocused")
				{
					result->Success(IsFocused());
				}
				else if (methodType == "blur")
				{
					Blur();
					result->Success(true);
				}
				else if (methodType == "focus")
				{
					Focus();
					result->Success(true);
				}
				else if (methodType == "isPreventClose")
				{
					result->Success(IsPreventClose());
				}
				else if (methodType == "SetPreventClose")
				{
					const flutter::EncodableMap &argsRef = *args;
					SetPreventClose(argsRef);
					result->Success(true);
				}
				else if (methodType == "close")
				{
					Close();
					result->Success(true);
				}
				else if (methodType == "setAsFrameless")
				{
					SetAsFrameless();
					result->Success(true);
				}
				else if (methodType == "getBounds")
				{
					const flutter::EncodableMap &argsRef = *args;
					result->Success(GetBounds(argsRef));
				}
				else if (methodType == "setResizable")
				{
					const flutter::EncodableMap &argsRef = *args;
					SetResizable(argsRef);
					result->Success(true);
				}
				else if (methodType == "isResizable")
				{
					result->Success(IsResizable());
				}
				else if (methodType == "minimize")
				{
					Minimize();
					result->Success(true);
				}
			}
		}
		catch (DWORD e)
		{
			auto str_code = this->GetErrorString(e);
			result->Error("Exception encountered: " + str_code, method);
		}
	}

	void MrtNativeSupport::Write(const std::string &key, const std::string &val)
	{
		// The recommended size for AES-GCM IV is 12 bytes
		const DWORD NONCE_SIZE = 12;
		const DWORD KEY_SIZE = 16;

		NTSTATUS status;
		BCRYPT_ALG_HANDLE algo = NULL;
		BCRYPT_KEY_HANDLE keyHandle = NULL;
		DWORD bytesWritten = 0,
			  ciphertextSize = 0;
		PBYTE ciphertext = NULL,
			  iv = (PBYTE)HeapAlloc(GetProcessHeap(), 0, NONCE_SIZE),
			  encryptionKey = GetEncryptionKey();
		BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO authInfo{};
		BCRYPT_AUTH_TAG_LENGTHS_STRUCT authTagLengths{};
		std::basic_ofstream<BYTE> fs;
		std::wstring appSupportPath;
		std::string error;

		if (iv == NULL)
		{
			error = "IV HeapAlloc Failed";
			goto err;
		}
		if (encryptionKey == NULL)
		{
			error = "encryptionKey is NULL";
			goto err;
		}
		status = BCryptOpenAlgorithmProvider(&algo, BCRYPT_AES_ALGORITHM, NULL, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptOpenAlgorithmProvider", status);
			goto err;
		}
		status = BCryptSetProperty(algo, BCRYPT_CHAINING_MODE, (PUCHAR)BCRYPT_CHAIN_MODE_GCM, sizeof(BCRYPT_CHAIN_MODE_GCM), 0);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptSetProperty", status);
			goto err;
		}
		status = BCryptGetProperty(algo, BCRYPT_AUTH_TAG_LENGTH, (PBYTE)&authTagLengths, sizeof(BCRYPT_AUTH_TAG_LENGTHS_STRUCT), &bytesWritten, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptGetProperty", status);
			goto err;
		}
		BCRYPT_INIT_AUTH_MODE_INFO(authInfo);
		authInfo.pbNonce = (PUCHAR)HeapAlloc(GetProcessHeap(), 0, NONCE_SIZE);
		if (authInfo.pbNonce == NULL)
		{
			error = "pbNonce HeapAlloc Failed";
			goto err;
		}
		authInfo.cbNonce = NONCE_SIZE;
		status = BCryptGenRandom(NULL, iv, authInfo.cbNonce, BCRYPT_USE_SYSTEM_PREFERRED_RNG);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptGenRandom", status);
			goto err;
		}
		// copy the original IV into the authInfo, we can't write the IV directly into the authInfo because it will change after calling BCryptEncrypt and we still need to write the IV to file
		memcpy(authInfo.pbNonce, iv, authInfo.cbNonce);
		// We do not use additional authenticated data
		authInfo.pbAuthData = NULL;
		authInfo.cbAuthData = 0;
		// Make space for the authentication tag
		authInfo.pbTag = (PUCHAR)HeapAlloc(GetProcessHeap(), 0, authTagLengths.dwMaxLength);
		if (authInfo.pbTag == NULL)
		{
			error = "pbTag HeapAlloc Failed";
			goto err;
		}
		authInfo.cbTag = authTagLengths.dwMaxLength;
		status = BCryptGenerateSymmetricKey(algo, &keyHandle, NULL, 0, encryptionKey, KEY_SIZE, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptGenerateSymmetricKey", status);
			goto err;
		}
		// First call to BCryptEncrypt to get size of ciphertext
		status = BCryptEncrypt(keyHandle, (PUCHAR)val.c_str(), (ULONG)val.length() + 1, (PVOID)&authInfo, NULL, 0, NULL, 0, &bytesWritten, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptEncrypt1", status);
			goto err;
		}
		ciphertextSize = bytesWritten;
		ciphertext = (PBYTE)HeapAlloc(GetProcessHeap(), 0, ciphertextSize);
		if (ciphertext == NULL)
		{
			error = "CipherText HeapAlloc failed";
			goto err;
		}
		// Actual encryption
		status = BCryptEncrypt(keyHandle, (PUCHAR)val.c_str(), (ULONG)val.length() + 1, (PVOID)&authInfo, NULL, 0, ciphertext, ciphertextSize, &bytesWritten, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			error = NtStatusToString("BCryptEncrypt2", status);
			goto err;
		}
		GetApplicationSupportPath(appSupportPath);
		if (!PathExists(appSupportPath))
		{
			MakePath(appSupportPath);
		}
		fs = std::basic_ofstream<BYTE>(appSupportPath + L"\\" + std::wstring(key.begin(), key.end()) + L".secure", std::ios::binary | std::ios::trunc);
		if (!fs)
		{
			error = "Failed to open output stream";
			goto err;
		}
		fs.write(iv, NONCE_SIZE);
		fs.write(authInfo.pbTag, authInfo.cbTag);
		fs.write(ciphertext, ciphertextSize);
		fs.close();
		HeapFree(GetProcessHeap(), 0, iv);
		HeapFree(GetProcessHeap(), 0, encryptionKey);
		HeapFree(GetProcessHeap(), 0, authInfo.pbNonce);
		HeapFree(GetProcessHeap(), 0, authInfo.pbTag);
		HeapFree(GetProcessHeap(), 0, ciphertext);
		return;
	err:
		if (iv)
		{
			HeapFree(GetProcessHeap(), 0, iv);
		}
		if (encryptionKey)
		{
			HeapFree(GetProcessHeap(), 0, encryptionKey);
		}
		if (authInfo.pbNonce)
		{
			HeapFree(GetProcessHeap(), 0, authInfo.pbNonce);
		}
		if (authInfo.pbTag)
		{
			HeapFree(GetProcessHeap(), 0, authInfo.pbTag);
		}
		if (ciphertext)
		{
			HeapFree(GetProcessHeap(), 0, ciphertext);
		}
		throw std::runtime_error(error);
	}

	std::optional<std::string> MrtNativeSupport::Read(const std::string &key)
	{
		const DWORD NONCE_SIZE = 12;
		const DWORD KEY_SIZE = 16;

		NTSTATUS status;
		BCRYPT_ALG_HANDLE algo = NULL;
		BCRYPT_KEY_HANDLE keyHandle = NULL;
		BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO authInfo{};
		BCRYPT_AUTH_TAG_LENGTHS_STRUCT authTagLengths{};

		PBYTE encryptionKey = GetEncryptionKey(),
			  ciphertext = NULL,
			  fileBuffer = NULL,
			  plaintext = NULL;
		DWORD plaintextSize = 0,
			  bytesWritten = 0,
			  ciphertextSize = 0;
		std::wstring appSupportPath;
		std::basic_ifstream<BYTE> fs;
		std::streampos fileSize;
		std::optional<std::string> returnVal = std::nullopt;

		if (encryptionKey == NULL)
		{
			std::cerr << "encryptionKey is NULL" << std::endl;
			goto cleanup;
		}
		GetApplicationSupportPath(appSupportPath);
		if (!PathExists(appSupportPath))
		{
			MakePath(appSupportPath);
		}
		// Read full file into a buffer
		fs = std::basic_ifstream<BYTE>(appSupportPath + L"\\" + std::wstring(key.begin(), key.end()) + L".secure", std::ios::binary);
		if (!fs.good())
		{
			// Backwards comp.
			PCREDENTIALW pcred;
			CA2W target_name(key.c_str());
			bool ok = CredReadW(target_name.m_psz, CRED_TYPE_GENERIC, 0, &pcred);
			if (ok)
			{
				auto val = std::string((char *)pcred->CredentialBlob);
				CredFree(pcred);
				returnVal = val;
			}
			goto cleanup;
		}
		fs.unsetf(std::ios::skipws);
		fs.seekg(0, std::ios::end);
		fileSize = fs.tellg();
		fs.seekg(0, std::ios::beg);
		fileBuffer = (PBYTE)HeapAlloc(GetProcessHeap(), 0, fileSize);
		if (NULL == fileBuffer)
		{
			std::cerr << "fileBuffer HeapAlloc failed" << std::endl;
			goto cleanup;
		}
		fs.read(fileBuffer, fileSize);
		fs.close();

		status = BCryptOpenAlgorithmProvider(&algo, BCRYPT_AES_ALGORITHM, NULL, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			std::cerr << NtStatusToString("BCryptOpenAlgorithmProvider", status) << std::endl;
			goto cleanup;
		}
		status = BCryptSetProperty(algo, BCRYPT_CHAINING_MODE, (PUCHAR)BCRYPT_CHAIN_MODE_GCM, sizeof(BCRYPT_CHAIN_MODE_GCM), 0);
		if (!BCRYPT_SUCCESS(status))
		{
			std::cerr << NtStatusToString("BCryptOpenAlgorithmProvider", status) << std::endl;
			goto cleanup;
		}
		status = BCryptGetProperty(algo, BCRYPT_AUTH_TAG_LENGTH, (PBYTE)&authTagLengths, sizeof(BCRYPT_AUTH_TAG_LENGTHS_STRUCT), &bytesWritten, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			std::cerr << NtStatusToString("BCryptGetProperty", status) << std::endl;
			goto cleanup;
		}

		BCRYPT_INIT_AUTH_MODE_INFO(authInfo);
		authInfo.pbNonce = (PUCHAR)HeapAlloc(GetProcessHeap(), 0, NONCE_SIZE);
		if (authInfo.pbNonce == NULL)
		{
			std::cerr << "pbNonce HeapAlloc Failed" << std::endl;
			goto cleanup;
		}
		authInfo.cbNonce = NONCE_SIZE;
		// Check if file is at least long enough for iv and authentication tag
		if (fileSize <= static_cast<long long>(NONCE_SIZE) + authTagLengths.dwMaxLength)
		{
			std::cerr << "File is too small" << std::endl;
			goto cleanup;
		}
		authInfo.pbTag = (PUCHAR)HeapAlloc(GetProcessHeap(), 0, authTagLengths.dwMaxLength);
		if (authInfo.pbTag == NULL)
		{
			std::cerr << "pbTag HeapAlloc Failed" << std::endl;
			goto cleanup;
		}
		ciphertextSize = (DWORD)fileSize - NONCE_SIZE - authTagLengths.dwMaxLength;
		ciphertext = (PBYTE)HeapAlloc(GetProcessHeap(), 0, ciphertextSize);
		if (ciphertext == NULL)
		{
			std::cerr << "ciphertext HeapAlloc failed" << std::endl;
			goto cleanup;
		}
		// Copy different parts needed for decryption from filebuffer
#pragma warning(push)
#pragma warning(disable : 6385)
		memcpy(authInfo.pbNonce, fileBuffer, NONCE_SIZE);
#pragma warning(pop)
		memcpy(authInfo.pbTag, &fileBuffer[NONCE_SIZE], authTagLengths.dwMaxLength);
		memcpy(ciphertext, &fileBuffer[NONCE_SIZE + authTagLengths.dwMaxLength], ciphertextSize);
		authInfo.cbTag = authTagLengths.dwMaxLength;

		status = BCryptGenerateSymmetricKey(algo, &keyHandle, NULL, 0, encryptionKey, KEY_SIZE, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			std::cerr << NtStatusToString("BCryptGenerateSymmetricKey", status) << std::endl;
			goto cleanup;
		}
		// First call is to determine size of plaintext
		status = BCryptDecrypt(keyHandle, ciphertext, ciphertextSize, (PVOID)&authInfo, NULL, 0, NULL, 0, &bytesWritten, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			std::cerr << NtStatusToString("BCryptDecrypt1", status) << std::endl;
			goto cleanup;
		}
		plaintextSize = bytesWritten;
		plaintext = (PBYTE)HeapAlloc(GetProcessHeap(), 0, plaintextSize);
		if (NULL == plaintext)
		{
			std::cerr << "plaintext HeapAlloc failed" << std::endl;
			goto cleanup;
		}
		// Actuual decryption
		status = BCryptDecrypt(keyHandle, ciphertext, ciphertextSize, (PVOID)&authInfo, NULL, 0, plaintext, plaintextSize, &bytesWritten, 0);
		if (!BCRYPT_SUCCESS(status))
		{
			std::cerr << NtStatusToString("BCryptDecrypt2", status) << std::endl;
			goto cleanup;
		}
		returnVal = (char *)plaintext;
	cleanup:
		if (encryptionKey)
		{
			HeapFree(GetProcessHeap(), 0, encryptionKey);
		}
		if (ciphertext)
		{
			HeapFree(GetProcessHeap(), 0, ciphertext);
		}
		if (plaintext)
		{
			HeapFree(GetProcessHeap(), 0, plaintext);
		}
		if (fileBuffer)
		{
			HeapFree(GetProcessHeap(), 0, fileBuffer);
		}
		if (authInfo.pbNonce)
		{
			HeapFree(GetProcessHeap(), 0, authInfo.pbNonce);
		}
		if (authInfo.pbTag)
		{
			HeapFree(GetProcessHeap(), 0, authInfo.pbTag);
		}
		return returnVal;
	}

	flutter::EncodableMap MrtNativeSupport::ReadAll()
	{
		WIN32_FIND_DATA searchRes;
		HANDLE hFile;
		std::wstring appSupportPath;

		GetApplicationSupportPath(appSupportPath);
		if (!PathExists(appSupportPath))
		{
			MakePath(appSupportPath);
		}
		hFile = FindFirstFile((appSupportPath + L"\\*.secure").c_str(), &searchRes);
		if (hFile == INVALID_HANDLE_VALUE)
		{
			return flutter::EncodableMap();
		}

		flutter::EncodableMap creds;

		do
		{
			std::wstring fileName(searchRes.cFileName);
			size_t pos = fileName.find(L".secure");
			fileName.erase(pos, 7);
			char *out = new char[fileName.length() + 1];
			size_t charsConverted = 0;
			wcstombs_s(&charsConverted, out, fileName.length() + 1, fileName.c_str(), fileName.length() + 1);
			std::optional<std::string> val = this->Read(out);
			auto key = this->RemoveKeyPrefix(out);
			if (val.has_value())
			{
				creds[key] = val.value();
				continue;
			}
		} while (FindNextFile(hFile, &searchRes) != 0);

		// Backwards comp.
		PCREDENTIALW *pcreds;
		DWORD cred_count = 0;
		bool ok = CredEnumerateW(CREDENTIAL_FILTER.m_psz, 0, &cred_count, &pcreds);
		if (!ok)
		{
			return creds;
		}
		for (DWORD i = 0; i < cred_count; i++)
		{
			auto pcred = pcreds[i];
			std::string target_name = CW2A(pcred->TargetName);
			auto val = std::string((char *)pcred->CredentialBlob);
			auto key = this->RemoveKeyPrefix(target_name);
			// If the key exists then data was already read from a file, which implies that the data read from the credential system is outdated
			if (creds.find(key) == creds.end())
			{
				creds[key] = val;
			}
		}

		CredFree(pcreds);
		return creds;
	}

	void MrtNativeSupport::Delete(const std::string &key)
	{
		std::wstring appSupportPath;
		GetApplicationSupportPath(appSupportPath);
		auto wstr = std::wstring(key.begin(), key.end());
		BOOL ok = DeleteFile((appSupportPath + L"\\" + wstr + L".secure").c_str());
		if (!ok)
		{
			DWORD error = GetLastError();
			if (error != ERROR_FILE_NOT_FOUND && error != ERROR_PATH_NOT_FOUND)
			{
				throw error;
			}
		}

		// Backwards comp.
		ok = CredDeleteW(wstr.c_str(), CRED_TYPE_GENERIC, 0);
		if (!ok)
		{
			auto error = GetLastError();

			// Silently ignore if we try to delete a key that doesn't exist
			if (error == ERROR_NOT_FOUND)
				return;

			throw error;
		}
	}

	void MrtNativeSupport::DeleteAll()
	{

		WIN32_FIND_DATA searchRes;
		HANDLE hFile;
		std::wstring appSupportPath;

		GetApplicationSupportPath(appSupportPath);
		if (!PathExists(appSupportPath))
		{
			MakePath(appSupportPath);
		}
		hFile = FindFirstFile((appSupportPath + L"\\*.secure").c_str(), &searchRes);
		if (hFile == INVALID_HANDLE_VALUE)
		{
			return;
		}
		do
		{
			std::wstring fileName(searchRes.cFileName);
			BOOL ok = DeleteFile((appSupportPath + L"\\" + fileName).c_str());
			if (!ok)
			{
				DWORD error = GetLastError();
				if (error != ERROR_FILE_NOT_FOUND)
				{
					throw error;
				}
			}
		} while (FindNextFile(hFile, &searchRes) != 0);

		// Backwards comp.
		PCREDENTIALW *pcreds;
		DWORD cred_count = 0;

		bool read_ok = CredEnumerateW(CREDENTIAL_FILTER.m_psz, 0, &cred_count, &pcreds);
		if (!read_ok)
		{
			auto error = GetLastError();
			if (error == ERROR_NOT_FOUND)
				// No credentials to delete
				return;
			throw error;
		}

		for (DWORD i = 0; i < cred_count; i++)
		{
			auto pcred = pcreds[i];
			auto target_name = pcred->TargetName;

			bool delete_ok = CredDeleteW(target_name, CRED_TYPE_GENERIC, 0);
			if (!delete_ok)
			{
				throw GetLastError();
			}
		}

		CredFree(pcreds);
	}

	bool MrtNativeSupport::ContainsKey(const std::string &key)
	{
		std::wstring appSupportPath;
		GetApplicationSupportPath(appSupportPath);
		std::wstring wstr = std::wstring(key.begin(), key.end());
		if (INVALID_FILE_ATTRIBUTES == GetFileAttributes((appSupportPath + L"\\" + wstr + L".secure").c_str()))
		{
			// Backwards comp.
			PCREDENTIALW pcred;
			CA2W target_name(key.c_str());

			bool ok = CredReadW(target_name.m_psz, CRED_TYPE_GENERIC, 0, &pcred);
			if (ok)
				return true;

			auto error = GetLastError();
			if (error == ERROR_NOT_FOUND)
				return false;
			throw error;
		}
		return true;
	}
	bool MrtNativeSupport::LaunchUrl(const std::string &url)
	{
		// Convert the std::string to LPCSTR
		LPCSTR urlLpcstr = url.c_str();

		// Launch the URL using ShellExecute
		HINSTANCE result = ShellExecuteA(NULL, "open", urlLpcstr, NULL, NULL, SW_SHOWNORMAL);

		// Check if the operation was successful
		if ((intptr_t)result > 32)
		{
			// Success
			return true;
		}
		else
		{
			// Failure
			return false;
		}
	}

	flutter::EncodableMap MrtNativeSupport::getPaths()
	{
		flutter::EncodableMap paths;
		// Function to calculate the application-specific subdirectory
		auto getAppSpecificSubdirectory = [](const wchar_t *baseFolder, const wchar_t *subfolder) -> std::wstring
		{
			std::wstring fullPath(baseFolder);
			fullPath += L"\\";
			fullPath += subfolder;
			return fullPath;
		};
		// Document Path
		PWSTR docPath;
		if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Documents, 0, NULL, &docPath)))
		{
			std::wstring wideDocPath(docPath);
			CoTaskMemFree(docPath);

			// Convert wide string to BSTR
			BSTR bstrDocPath = SysAllocString(wideDocPath.c_str());

			// Convert BSTR to UTF-8 string
			std::string utf8DocPath = _com_util::ConvertBSTRToString(bstrDocPath);

			// Add to paths map
			paths[flutter::EncodableValue("document")] = flutter::EncodableValue(utf8DocPath);

			// Don't forget to free the allocated BSTR
			SysFreeString(bstrDocPath);
		}

		// Cache Path (LocalAppData)
		PWSTR cachePath;
		if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, NULL, &cachePath)))
		{
			std::wstring wideCachePath(cachePath);
			CoTaskMemFree(cachePath);

			// Calculate application-specific subdirectory within LocalAppData
			std::wstring appSpecificCachePath = getAppSpecificSubdirectory(wideCachePath.c_str(), L"MRTNETWORK");

			// Convert wide string to BSTR
			BSTR bstrAppSpecificCachePath = SysAllocString(appSpecificCachePath.c_str());

			// Convert BSTR to UTF-8 string
			std::string utf8AppSpecificCachePath = _com_util::ConvertBSTRToString(bstrAppSpecificCachePath);

			// Add to paths map
			paths[flutter::EncodableValue("cache")] = flutter::EncodableValue(utf8AppSpecificCachePath);

			// Don't forget to free the allocated BSTR
			SysFreeString(bstrAppSpecificCachePath);
		}

		// App Support Path (RoamingAppData)
		PWSTR appSupportPath;
		if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_RoamingAppData, 0, NULL, &appSupportPath)))
		{
			std::wstring wideAppSupportPath(appSupportPath);
			CoTaskMemFree(appSupportPath);

			// Calculate application-specific subdirectory within RoamingAppData
			std::wstring appSpecificSupportPath = getAppSpecificSubdirectory(wideAppSupportPath.c_str(), L"MRTNETWORK");

			// Convert wide string to BSTR
			BSTR bstrAppSpecificSupportPath = SysAllocString(appSpecificSupportPath.c_str());

			// Convert BSTR to UTF-8 string
			std::string utf8AppSpecificSupportPath = _com_util::ConvertBSTRToString(bstrAppSpecificSupportPath);

			// Add to paths map
			paths[flutter::EncodableValue("support")] = flutter::EncodableValue(utf8AppSpecificSupportPath);

			// Don't forget to free the allocated BSTR
			SysFreeString(bstrAppSpecificSupportPath);
		}

		return paths;
	}

	HWND MrtNativeSupport::GetMainWindow()
	{
		return native_window;
	}

	void MrtNativeSupport::HandleFocusChange(bool hasFocus)
	{
	}
	std::optional<LRESULT> MrtNativeSupport::HandleWindowProc(HWND hWnd,
															  UINT message,
															  WPARAM wParam,
															  LPARAM lParam)
	{
		std::optional<LRESULT> result = std::nullopt;
		if (message == WM_DPICHANGED)
		{
			pixel_ratio_ = (float)LOWORD(wParam) / USER_DEFAULT_SCREEN_DPI;
		}
		if (message == HC_ACTION && wParam == WM_KEYDOWN)
		{
			std::cerr << "fileBuffer HeapAlloc failed" << std::endl;
		}
		if (wParam && message == WM_NCCALCSIZE)
		{
			if (g_is_window_fullscreen && title_bar_style_ != "normal")
			{
				if (is_frameless_)
				{
					NCCALCSIZE_PARAMS *sz = reinterpret_cast<NCCALCSIZE_PARAMS *>(lParam);
					sz->rgrc[0].left += 8;
					sz->rgrc[0].top += 8;
					sz->rgrc[0].right -= 8;
					sz->rgrc[0].bottom -= 8;
				}
				return 0;
			}
			if (is_frameless_)
			{
				NCCALCSIZE_PARAMS *sz = reinterpret_cast<NCCALCSIZE_PARAMS *>(lParam);
				if (IsMaximized())
				{
					// Add borders when maximized so app doesn't get cut off.
					sz->rgrc[0].left += 8;
					sz->rgrc[0].top += 8;
					sz->rgrc[0].right -= 8;
					sz->rgrc[0].bottom -= 9;
				}
				return 0;
			}
			// This must always be last.
			if (wParam && title_bar_style_ == "hidden")
			{
				NCCALCSIZE_PARAMS *sz = reinterpret_cast<NCCALCSIZE_PARAMS *>(lParam);

				// Add 8 pixel to the top border when maximized so the app isn't cut off
				if (IsMaximized())
				{
					sz->rgrc[0].top += 8;
				}
				else
				{
					// on windows 10, if set to 0, there's a white line at the top
					// of the app and I've yet to find a way to remove that.
					sz->rgrc[0].top += IsWindows11OrGreater() ? 0 : 1;
				}
				sz->rgrc[0].right -= 8;
				sz->rgrc[0].bottom -= 8;
				sz->rgrc[0].left -= -8;

				// Previously (WVR_HREDRAW | WVR_VREDRAW), but returning 0 or 1 doesn't
				// actually break anything so I've set it to 0. Unless someone pointed a
				// problem in the future.
				return 0;
			}
		}
		else if (message == WM_NCHITTEST)
		{
			if (!is_resizable_)
			{
				return HTNOWHERE;
			}
		}
		else if (message == WM_GETMINMAXINFO)
		{
			MINMAXINFO *info = reinterpret_cast<MINMAXINFO *>(lParam);
			// For the special "unconstrained" values, leave the defaults.
			if (minimum_size_.x != 0)
				info->ptMinTrackSize.x =
					static_cast<LONG>(minimum_size_.x *
									  pixel_ratio_);
			if (minimum_size_.y != 0)
				info->ptMinTrackSize.y =
					static_cast<LONG>(minimum_size_.y *
									  pixel_ratio_);
			if (maximum_size_.x != -1)
				info->ptMaxTrackSize.x =
					static_cast<LONG>(maximum_size_.x *
									  pixel_ratio_);
			if (maximum_size_.y != -1)
				info->ptMaxTrackSize.y =
					static_cast<LONG>(maximum_size_.y *
									  pixel_ratio_);
			result = 0;
		}
		else if (message == WM_NCACTIVATE)
		{
			if (wParam == TRUE)
			{
				_EmitEvent("focus");
			}
			else
			{
				_EmitEvent("blur");
			}

			if (title_bar_style_ == "hidden" ||
				is_frameless_)
				return 1;
		}
		else if (message == WM_EXITSIZEMOVE)
		{
			if (is_resizing_)
			{
				_EmitEvent("resized");
				is_resizing_ = false;
			}
			if (is_moving_)
			{
				_EmitEvent("moved");
				is_moving_ = false;
			}
			return false;
		}
		else if (message == WM_MOVING)
		{
			is_moving_ = true;
			_EmitEvent("move");
			return false;
		}
		else if (message == WM_SIZING)
		{
			is_resizing_ = true;
			_EmitEvent("resize");

			if (aspect_ratio_ > 0)
			{
				RECT *rect = (LPRECT)lParam;

				double aspect_ratio = aspect_ratio_;

				int new_width = static_cast<int>(rect->right - rect->left);
				int new_height = static_cast<int>(rect->bottom - rect->top);

				bool is_resizing_horizontally =
					wParam == WMSZ_LEFT || wParam == WMSZ_RIGHT ||
					wParam == WMSZ_TOPLEFT || wParam == WMSZ_BOTTOMLEFT;

				if (is_resizing_horizontally)
				{
					new_height = static_cast<int>(new_width / aspect_ratio);
				}
				else
				{
					new_width = static_cast<int>(new_height * aspect_ratio);
				}

				int left = rect->left;
				int top = rect->top;
				int right = rect->right;
				int bottom = rect->bottom;

				switch (wParam)
				{
				case WMSZ_RIGHT:
				case WMSZ_BOTTOM:
					right = new_width + left;
					bottom = top + new_height;
					break;
				case WMSZ_TOP:
					right = new_width + left;
					top = bottom - new_height;
					break;
				case WMSZ_LEFT:
				case WMSZ_TOPLEFT:
					left = right - new_width;
					top = bottom - new_height;
					break;
				case WMSZ_TOPRIGHT:
					right = left + new_width;
					top = bottom - new_height;
					break;
				case WMSZ_BOTTOMLEFT:
					left = right - new_width;
					bottom = top + new_height;
					break;
				case WMSZ_BOTTOMRIGHT:
					right = left + new_width;
					bottom = top + new_height;
					break;
				}

				rect->left = left;
				rect->top = top;
				rect->right = right;
				rect->bottom = bottom;
			}
		}
		else if (message == WM_SIZE)
		{
			LONG_PTR gwlStyle =
				GetWindowLongPtr(GetMainWindow(), GWL_STYLE);
			if ((gwlStyle & (WS_CAPTION | WS_THICKFRAME)) == 0 &&
				wParam == SIZE_MAXIMIZED)
			{
				_EmitEvent("enter-full-screen");
				last_state = STATE_FULLSCREEN_ENTERED;
			}
			else if (last_state == STATE_FULLSCREEN_ENTERED &&
					 wParam == SIZE_RESTORED)
			{
				ForceChildRefresh();
				_EmitEvent("leave-full-screen");
				last_state = STATE_NORMAL;
			}
			else if (wParam == SIZE_MAXIMIZED)
			{
				_EmitEvent("maximize");
				last_state = STATE_MAXIMIZED;
			}
			else if (wParam == SIZE_MINIMIZED)
			{
				_EmitEvent("minimize");
				last_state = STATE_MINIMIZED;
				return 0;
			}
			else if (wParam == SIZE_RESTORED)
			{
				if (last_state == STATE_MAXIMIZED)
				{
					_EmitEvent("unmaximize");
					last_state = STATE_NORMAL;
				}
				else if (last_state == STATE_MINIMIZED)
				{
					_EmitEvent("restore");
					last_state = STATE_NORMAL;
				}
			}
		}
		else if (message == WM_CLOSE)
		{
			_EmitEvent("close");
			if (is_prevent_close_)
			{
				return -1;
			}
		}
		else if (message == WM_SHOWWINDOW)
		{
			if (wParam == TRUE)
			{
				_EmitEvent("show");
			}
			else
			{
				_EmitEvent("hide");
			}
		}
		else if (message == WM_WINDOWPOSCHANGED)
		{
			if (is_always_on_bottom_)
			{
				const flutter::EncodableMap &args = {
					{flutter::EncodableValue("isAlwaysOnBottom"),
					 flutter::EncodableValue(true)}};
				SetAlwaysOnBottom(args);
			}
		}

		return result;
	}

	bool MrtNativeSupport::IsMaximized()
	{
		HWND mainWindow = GetMainWindow();
		WINDOWPLACEMENT windowPlacement;
		GetWindowPlacement(mainWindow, &windowPlacement);

		return windowPlacement.showCmd == SW_MAXIMIZE;
	}
	bool MrtNativeSupport::SetMaximumSize(const flutter::EncodableMap &argsRef)
	{
		// Assuming "maxWidth" and "maxHeight" are the keys in the EncodableMap
		if (argsRef.find(flutter::EncodableValue("width")) != argsRef.end() &&
			argsRef.find(flutter::EncodableValue("height")) != argsRef.end())
		{

			double maxWidth = std::get<double>(argsRef.at(flutter::EncodableValue("height")));
			double maxHeight = std::get<double>(argsRef.at(flutter::EncodableValue("height")));

			maximum_size_.x = static_cast<LONG>(maxWidth);
			maximum_size_.y = static_cast<LONG>(maxHeight);
			return true;
		}
		return false;
	}
	bool MrtNativeSupport::SetMinimumSize(const flutter::EncodableMap &argsRef)
	{
		if (argsRef.find(flutter::EncodableValue("width")) != argsRef.end() &&
			argsRef.find(flutter::EncodableValue("height")) != argsRef.end())
		{

			double minWidth = std::get<double>(argsRef.at(flutter::EncodableValue("width")));
			double minHeight = std::get<double>(argsRef.at(flutter::EncodableValue("height")));

			minimum_size_.x = static_cast<LONG>(minWidth);
			minimum_size_.y = static_cast<LONG>(minHeight);
			return true;
		}
		return false;
	}
	void MrtNativeSupport::SetAlwaysOnBottom(const flutter::EncodableMap &args)
	{
		is_always_on_bottom_ =
			std::get<bool>(args.at(flutter::EncodableValue("isAlwaysOnBottom")));

		SetWindowPos(
			GetMainWindow(),
			is_always_on_bottom_ ? HWND_BOTTOM : HWND_NOTOPMOST,
			0,
			0,
			0,
			0,
			SWP_NOMOVE | SWP_NOSIZE);
	}
	void MrtNativeSupport::ForceChildRefresh()
	{
		HWND hWnd = GetWindow(GetMainWindow(), GW_CHILD);

		RECT rect;

		GetWindowRect(hWnd, &rect);
		SetWindowPos(
			hWnd, nullptr, rect.left, rect.top, rect.right - rect.left + 1,
			rect.bottom - rect.top,
			SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_FRAMECHANGED);
		SetWindowPos(
			hWnd, nullptr, rect.left, rect.top, rect.right - rect.left,
			rect.bottom - rect.top,
			SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_FRAMECHANGED);
	}
	void MrtNativeSupport::_EmitEvent(std::string eventName)
	{
		flutter::EncodableMap args = flutter::EncodableMap();
		args[flutter::EncodableValue("eventName")] =
			flutter::EncodableValue(eventName);
		channel_->InvokeMethod("onEvent",
							   std::make_unique<flutter::EncodableValue>(args));
	}
	void MrtNativeSupport::Hide()
	{
		ShowWindow(GetMainWindow(), SW_HIDE);
	}
	void MrtNativeSupport::Show()
	{
		HWND hWnd = GetMainWindow();
		DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
		gwlStyle = gwlStyle | WS_VISIBLE;
		if ((gwlStyle & WS_VISIBLE) == 0)
		{
			SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
			::SetWindowPos(hWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
		}

		ShowWindowAsync(GetMainWindow(), SW_SHOW);
		SetForegroundWindow(GetMainWindow());
	}

	void MrtNativeSupport::Init()
	{
		native_window = ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
	}
	void MrtNativeSupport::SetBounds(const flutter::EncodableMap &args)
	{
		HWND hwnd = GetMainWindow();

		double devicePixelRatio =
			std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

		auto *null_or_x = std::get_if<double>(ValueOrNull(args, "x"));
		auto *null_or_y = std::get_if<double>(ValueOrNull(args, "y"));
		auto *null_or_width = std::get_if<double>(ValueOrNull(args, "width"));
		auto *null_or_height = std::get_if<double>(ValueOrNull(args, "height"));

		int x = 0;
		int y = 0;
		int width = 0;
		int height = 0;
		UINT uFlags = NULL;

		if (null_or_x != nullptr && null_or_y != nullptr)
		{
			x = static_cast<int>(*null_or_x * devicePixelRatio);
			y = static_cast<int>(*null_or_y * devicePixelRatio);
		}
		if (null_or_width != nullptr && null_or_height != nullptr)
		{
			width = static_cast<int>(*null_or_width * devicePixelRatio);
			height = static_cast<int>(*null_or_height * devicePixelRatio);
		}

		if (null_or_x == nullptr || null_or_y == nullptr)
		{
			uFlags = SWP_NOMOVE;
		}
		if (null_or_width == nullptr || null_or_height == nullptr)
		{
			uFlags = SWP_NOSIZE;
		}

		SetWindowPos(hwnd, HWND_TOP, x, y, width, height, uFlags);
	}
	bool MrtNativeSupport::IsFullScreen()
	{
		return g_is_window_fullscreen;
	}
	bool MrtNativeSupport::IsMinimized()
	{
		HWND mainWindow = GetMainWindow();
		WINDOWPLACEMENT windowPlacement;
		GetWindowPlacement(mainWindow, &windowPlacement);

		return windowPlacement.showCmd == SW_SHOWMINIMIZED;
	}

	void MrtNativeSupport::SetFullScreen(const flutter::EncodableMap &args)
	{
		bool isFullScreen =
			std::get<bool>(args.at(flutter::EncodableValue("isFullScreen")));

		HWND mainWindow = GetMainWindow();

		// Previously inspired by how Chromium does this
		// https://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/fullscreen_handler.cc?revision=247204&view=markup
		// Instead, we use a modified implementation of how the media_kit package implements this
		// (we got permission from the author, I believe)
		// https://github.com/alexmercerind/media_kit/blob/1226bcff36eab27cb17d60c33e9c15ca489c1f06/media_kit_video/windows/utils.cc

		// Save current window state if not already fullscreen.
		if (!g_is_window_fullscreen)
		{
			// Save current window information.
			g_maximized_before_fullscreen = ::IsZoomed(mainWindow);
			g_style_before_fullscreen = GetWindowLong(mainWindow, GWL_STYLE);
			::GetWindowRect(mainWindow, &g_frame_before_fullscreen);
			g_title_bar_style_before_fullscreen = title_bar_style_;
		}

		if (isFullScreen)
		{
			::SendMessage(mainWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
			if (!is_frameless_)
			{
				auto monitor = MONITORINFO{};
				auto placement = WINDOWPLACEMENT{};
				monitor.cbSize = sizeof(MONITORINFO);
				placement.length = sizeof(WINDOWPLACEMENT);
				::GetWindowPlacement(mainWindow, &placement);
				::GetMonitorInfo(::MonitorFromWindow(mainWindow, MONITOR_DEFAULTTONEAREST),
								 &monitor);
				::SetWindowLongPtr(mainWindow, GWL_STYLE, g_style_before_fullscreen & ~WS_OVERLAPPEDWINDOW);
				::SetWindowPos(mainWindow, HWND_TOP, monitor.rcMonitor.left,
							   monitor.rcMonitor.top, monitor.rcMonitor.right - monitor.rcMonitor.left,
							   monitor.rcMonitor.bottom - monitor.rcMonitor.top,
							   SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
			}
		}
		else
		{
			if (!g_maximized_before_fullscreen)
				Restore();
			::SetWindowLongPtr(mainWindow, GWL_STYLE, g_style_before_fullscreen | WS_OVERLAPPEDWINDOW);
			if (::IsZoomed(mainWindow))
			{
				// Refresh the parent mainWindow.
				::SetWindowPos(mainWindow, nullptr, 0, 0, 0, 0,
							   SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
								   SWP_FRAMECHANGED);
				auto rect = RECT{};
				::GetClientRect(mainWindow, &rect);
				auto flutter_view =
					::FindWindowEx(mainWindow, nullptr, kFlutterViewWindowClassName, nullptr);
				::SetWindowPos(flutter_view, nullptr, rect.left, rect.top,
							   rect.right - rect.left, rect.bottom - rect.top,
							   SWP_NOACTIVATE | SWP_NOZORDER);
				if (g_maximized_before_fullscreen)
					PostMessage(mainWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
			}
			else
			{
				::SetWindowPos(
					mainWindow, nullptr, g_frame_before_fullscreen.left,
					g_frame_before_fullscreen.top,
					g_frame_before_fullscreen.right - g_frame_before_fullscreen.left,
					g_frame_before_fullscreen.bottom - g_frame_before_fullscreen.top,
					SWP_NOACTIVATE | SWP_NOZORDER);
			}
		}

		g_is_window_fullscreen = isFullScreen;
	}
	void MrtNativeSupport::Restore()
	{
		HWND mainWindow = GetMainWindow();
		WINDOWPLACEMENT windowPlacement;
		GetWindowPlacement(mainWindow, &windowPlacement);

		if (windowPlacement.showCmd != SW_NORMAL)
		{
			PostMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
		}
	}
	void MrtNativeSupport::WaitUntilReadyToShow()
	{
		::CoCreateInstance(CLSID_TaskbarList, NULL, CLSCTX_INPROC_SERVER,
						   IID_PPV_ARGS(&taskbar_));
	}
	void MrtNativeSupport::Unmaximize()
	{
		HWND mainWindow = GetMainWindow();
		WINDOWPLACEMENT windowPlacement;
		GetWindowPlacement(mainWindow, &windowPlacement);

		if (windowPlacement.showCmd != SW_NORMAL)
		{
			PostMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
		}
	}
	bool MrtNativeSupport::IsVisible()
	{
		bool isVisible = IsWindowVisible(GetMainWindow());
		return isVisible;
	}
	bool MrtNativeSupport::IsFocused()
	{
		return GetMainWindow() == GetActiveWindow();
	}
	void MrtNativeSupport::Blur()
	{
		HWND hWnd = GetMainWindow();
		HWND next_hwnd = ::GetNextWindow(hWnd, GW_HWNDNEXT);
		while (next_hwnd)
		{
			if (::IsWindowVisible(next_hwnd))
			{
				::SetForegroundWindow(next_hwnd);
				return;
			}
			next_hwnd = ::GetNextWindow(next_hwnd, GW_HWNDNEXT);
		}
	}
	void MrtNativeSupport::Focus()
	{
		HWND hWnd = GetMainWindow();
		if (IsMinimized())
		{
			Restore();
		}

		::SetWindowPos(hWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
		SetForegroundWindow(hWnd);
	}
	bool MrtNativeSupport::IsPreventClose()
	{
		return is_prevent_close_;
	}
	void MrtNativeSupport::SetPreventClose(const flutter::EncodableMap &args)
	{

		is_prevent_close_ =
			std::get<bool>(args.at(flutter::EncodableValue("isPreventClose")));
	}
	void MrtNativeSupport::Close()
	{
		HWND hWnd = GetMainWindow();
		PostMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
	}
	void MrtNativeSupport::SetAsFrameless()
	{
		is_frameless_ = true;
		HWND hWnd = GetMainWindow();

		RECT rect;

		GetWindowRect(hWnd, &rect);
		SetWindowPos(hWnd, nullptr, rect.left, rect.top, rect.right - rect.left,
					 rect.bottom - rect.top,
					 SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE |
						 SWP_FRAMECHANGED);
	}
	flutter::EncodableMap MrtNativeSupport::GetBounds(
		const flutter::EncodableMap &args)
	{
		HWND hwnd = GetMainWindow();
		double devicePixelRatio =
			std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

		flutter::EncodableMap resultMap = flutter::EncodableMap();
		RECT rect;
		if (GetWindowRect(hwnd, &rect))
		{
			double x = rect.left / devicePixelRatio * 1.0f;
			double y = rect.top / devicePixelRatio * 1.0f;
			double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
			double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

			resultMap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
			resultMap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
			resultMap[flutter::EncodableValue("width")] =
				flutter::EncodableValue(width);
			resultMap[flutter::EncodableValue("height")] =
				flutter::EncodableValue(height);
		}
		return resultMap;
	}
	void MrtNativeSupport::SetResizable(const flutter::EncodableMap &args)
	{
		HWND hWnd = GetMainWindow();
		is_resizable_ =
			std::get<bool>(args.at(flutter::EncodableValue("isResizable")));
		DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
		if (is_resizable_)
		{
			gwlStyle |= WS_THICKFRAME;
		}
		else
		{
			gwlStyle &= ~WS_THICKFRAME;
		}
		::SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
	}
	bool MrtNativeSupport::IsResizable()
	{
		return is_resizable_;
	}
	void MrtNativeSupport::Minimize()
	{
		HWND mainWindow = GetMainWindow();
		WINDOWPLACEMENT windowPlacement;
		GetWindowPlacement(mainWindow, &windowPlacement);

		if (windowPlacement.showCmd != SW_SHOWMINIMIZED)
		{
			PostMessage(mainWindow, WM_SYSCOMMAND, SC_MINIMIZE, 0);
		}
	}

}
