FROM ubuntu:20.04

ENV GODOT_VERSION "4.3"
ENV CLI_TOOLS_VERSION "8512546_latest"

RUN apt update
RUN apt install -y unzip wget

RUN mkdir -p /opt/staging/build-templates
RUN mkdir -p /opt/staging/android-sdk

WORKDIR /opt/staging/build-templates

#RUN wget "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
RUN wget "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
#RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz
RUN unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz
RUN pwd
RUN ls -l

WORKDIR /opt/staging/android-sdk

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${CLI_TOOLS_VERSION}.zip
RUN unzip commandlinetools-linux-${CLI_TOOLS_VERSION}.zip -d cmdline-tools

FROM ubuntu:20.04

RUN apt update && apt install -y openjdk-17-jdk

RUN mkdir -p /root/.cache
RUN mkdir -p /root/.android
RUN mkdir -p /root/.config/godot
RUN mkdir -p /root/.local/share/godot/templates/${GODOT_VERSION}.stable
RUN mkdir -p /usr/lib/android-sdk
RUN mkdir -p /root/godot

COPY --from=0 /opt/staging/build-templates/templates/android_debug.apk /root/.local/share/godot/templates/${GODOT_VERSION}.stable/android_debug.apk
COPY --from=0 /opt/staging/build-templates/templates/android_release.apk /root/.local/share/godot/templates/${GODOT_VERSION}.stable/android_release.apk
COPY --from=0 /opt/staging/build-templates/templates/android_source.zip /root/.local/share/godot/templates/${GODOT_VERSION}.stable/android_source.zip
COPY --from=0 /opt/staging/android-sdk/cmdline-tools /usr/lib/android-sdk

ENV ANDROID_HOME "/usr/lib/android-sdk"
ENV PATH "${ANDROID_HOME}/cmdline-tools/bin:${PATH}"

RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "build-tools;35.0.0" "platforms;android-34" "cmdline-tools;latest" "cmake;3.10.2.4988404"

WORKDIR /root/.android/
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999


RUN apt install -y wget unzip
ENV GODOT_VERSION "4.3"
RUN echo  "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
RUN wget "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
RUN unzip "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
RUN cp "Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/bin/godot
RUN mv "Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot
RUN chmod 777 /usr/bin/godot

RUN godot --headless -e -q --quit

RUN update-alternatives --list java

RUN echo 'export/android/java_sdk_path = "/usr/lib/jvm/java-17-openjdk-amd64"' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/android_sdk_path = "/usr/lib/android-sdk"' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/debug_keystore = "/root/.android/debug.keystore"' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/debug_keystore_pass = "android"' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/force_system_user = false' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/timestamping_authority_url = ""' >> /root/.config/godot/editor_settings-4.3.tres
RUN echo 'export/android/shutdown_adb_on_exit = true' >> /root/.config/godot/editor_settings-4.3.tres

RUN ls /root/.config/godot/
RUN cat /root/.config/godot/editor_settings-4.3.tres

WORKDIR /root/godot
