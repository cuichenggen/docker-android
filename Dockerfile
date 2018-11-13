FROM openjdk:8-jdk

ARG sdk_version=sdk-tools-linux-3859397.zip
ARG android_home=/opt/android/sdk

# download and install Android SDK
RUN mkdir -p ${android_home} && \
    curl --silent --show-error --location --fail --retry 3 --output /tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ANDROID_HOME ${android_home}
ENV ADB_INSTALL_TIMEOUT 120
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg && \
    sdkmanager --update && yes | sdkmanager --licenses && \
    sdkmanager "tools" "platform-tools" "emulator" "extras;android;m2repository" && \
    sdkmanager "build-tools;26.0.2" && \
    sdkmanager "platforms;android-22" && \
    sdkmanager "system-images;android-22;default;x86" && \
    sdkmanager --update && yes | sdkmanager --licenses && \
    sdkmanager --list
