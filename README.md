# Update App Flutter  

This Flutter project demonstrates how to check for app updates and prompt users to update their app version.  

## 📌 **Overview**  
This implementation ensures that users always run an up-to-date version of the app by:  
- Checking the **current installed version** of the app.  
- Comparing it with the **minimum required version** and **latest available version**.  
- Displaying **mandatory or optional update dialogs** accordingly.  

## **How It Works**  
1️⃣ **`UpdateApp`**:  
   - A wrapper widget that checks for updates when the app starts.  
   - Uses `package_info_plus` to get the current app version.  
   - Compares it with the latest version fetched from a simulated API (`AppVersion.fetchLatestVersion`).  
   - Uses `shared_preferences` to store user preferences regarding optional updates.  

2️⃣ **Dialogs**:  
   - **Mandatory Update Dialog**: Forces the user to update if the installed version is outdated.  
   - **Optional Update Dialog**: Gives the user the option to update now or later, with a "Do not ask again" checkbox.  

## 📦 **Dependencies**  
This project uses the following Flutter packages:  
- `package_info_plus` → Retrieve app version details.  
- `shared_preferences` → Store user preferences for update reminders.  
- `pub_semver` → Compare version numbers.  

## 🔹 **Flutter & Dart Versions**  
- **Flutter**: `3.29.1`  
- **Dart**: `3.7.0`  

## 🛠 **Installation & Running the App**  
Clone the repository and install dependencies:  
```sh
git clone https://github.com/ahmedsaad3/update-app-flutter.git  
cd update_app_flutter  
flutter pub get  
flutter run  
