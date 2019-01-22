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

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg && \
    sdkmanager --update && yes | sdkmanager --licenses && \
    sdkmanager "tools" "platform-tools" "emulator" && \
    sdkmanager "build-tools;26.0.2" && \
    sdkmanager "platforms;android-22" && \
    sdkmanager "system-images;android-22;default;x86" && \
    sdkmanager --list && \
    avdmanager create avd --force --name testAVD --abi default/x86 --package 'system-images;android-22;default;x86' --device "Nexus 6P" && \
    avdmanager list avd

ADD minidemo.tar.gz /root
RUN chmod +x /root/minidemo/gradlew && \
    /root/minidemo/gradlew build && \
    rm -rf /root/minidemo
