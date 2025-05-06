# Building the Airfryer Recipes App with Codemagic

This guide will help you set up Codemagic CI/CD to automatically build the Airfryer Recipes app APK.

## Prerequisites

1. A [Codemagic](https://codemagic.io/) account
2. Your Airfryer Recipes app repository pushed to GitHub, GitLab, or Bitbucket

## Step 1: Set Up Your Repository

Ensure your repository has the following structure:
```
airfryer-recipes/
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   ├── proguard-rules.pro
│   │   └── src/
│   ├── build.gradle
│   ├── gradle.properties
│   ├── settings.gradle
├── codemagic.yaml
├── lib/
├── pubspec.yaml
└── ...
```

## Step 2: Configure Codemagic

1. Log in to [Codemagic](https://codemagic.io/)
2. Add your repository to Codemagic
3. Select "Flutter App" as the project type
4. In the workflow editor, choose to use the `codemagic.yaml` file
5. Commit and push the `codemagic.yaml` file to your repository

## Step 3: Configure Signing

For a signed APK (required for Play Store), you need to add your keystore:

1. Go to Codemagic settings for your app
2. Navigate to "Environment variables"
3. Add the following variables:
   - `CM_KEYSTORE`: Base64 encoded keystore file
   - `CM_KEYSTORE_PASSWORD`: Keystore password
   - `CM_KEY_ALIAS`: Key alias
   - `CM_KEY_PASSWORD`: Key password

To encode your keystore to Base64:
```bash
base64 -i your_keystore.jks -o keystore_base64.txt
```

## Step 4: Start the Build

1. Click "Start new build"
2. Select the branch you want to build
3. Choose the workflow from your codemagic.yaml file
4. Click "Start Build"

## Step 5: Download the APK

Once the build completes successfully:
1. Go to the build page
2. Download the generated APK from the "Artifacts" section

## Troubleshooting

### Error: "Skipping build for Android because /Users/builder/clone/android runner does not exist"

This error typically happens when Codemagic can't find your Android configuration. Check:

1. Make sure your android directory is at the root of the repository
2. Ensure the codemagic.yaml file is at the root of the repository
3. If you're using a private repository, make sure Codemagic has the correct access permissions
4. Try setting the working directory explicitly in codemagic.yaml:
   ```yaml
   scripts:
     - name: Set Working Directory
       script: |
         cd $CM_BUILD_DIR
         ls -la  # This will show the directory contents
         flutter build apk --release
   ```

### Build Timeouts

If your build times out, increase the `max_build_duration` in your codemagic.yaml file.

### Signing Issues

If you're having trouble with signing:
1. Make sure your keystore file is correctly encoded in Base64
2. Double-check all passwords and aliases
3. Verify the signing configuration in your android/app/build.gradle file

## Additional Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Android Signing Documentation](https://developer.android.com/studio/publish/app-signing)