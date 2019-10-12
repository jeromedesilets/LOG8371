# Weka NSIS installation script
#
# Note: content between "Start: .../End: ..." comments could get replaced, so
#       DO NOT modify these sections.
#
# Author : FracPete (fracpete at waikato dot at dot nz)
# Version: $Revision: 1.10 $

# Start: Weka
!define WEKA_WEKA "Weka"
!define WEKA_VERSION "3.4.7"   # must be of form 'X.Y.Z'
!define WEKA_VERSION_HYPHEN "3-4-7"   # must be of form 'X-Y-Z'
!define WEKA_FILES "D:\development\projects\weka.previous_releases\weka-3-4-7"
!define WEKA_TEMPLATES "D:\development\projects\weka.release\nsis\templates"
!define WEKA_LINK_PREFIX "Weka 3.4"
!define WEKA_DIR "Weka-3-4"
!define WEKA_URL "http://www.cs.waikato.ac.nz/~ml/weka/"
!define WEKA_MLGROUP "Machine Learning Group, University of Waikato, Hamilton, NZ"
!define WEKA_HEADERIMAGE "D:\development\projects\weka.release\nsis\images\weka_new.bmp"
!define WEKA_JRE "D:\installs\windows\programming\java\jdk.14\j2re-1_4_2_11-windows-i586-p.exe"
!define WEKA_JRE_TEMP "jre_setup.exe"
!define WEKA_JRE_INSTALL "RunJREInstaller.bat"
!define WEKA_JRE_SUFFIX ""
# End: Weka

Name "Weka ${WEKA_VERSION}"

# Defines
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION "${WEKA_VERSION}"
!define COMPANY "${WEKA_MLGROUP}"
!define URL "${WEKA_URL}"

# MUI defines
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_WELCOMEPAGE_TITLE "Welcome to the Weka ${WEKA_VERSION} Setup Wizard"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULT_FOLDER ${WEKA_WEKA}
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${WEKA_HEADERIMAGE}"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start ${WEKA_WEKA}"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchProgram"

# Included files
!include Sections.nsh
!include MUI.nsh

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${WEKA_FILES}\COPYING"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes

# required so that Vista/Win 7 uninstaller will remove start menu shortcuts
RequestExecutionLevel admin

OutFile "weka-${WEKA_VERSION_HYPHEN}${WEKA_JRE_SUFFIX}.exe"
InstallDir $PROGRAMFILES\${WEKA_DIR}
CRCCheck on
XPStyle on
ShowInstDetails show
VIProductVersion ${WEKA_VERSION}.0
VIAddVersionKey ProductName "${WEKA_WEKA}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion ""
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show

# Installer options
InstType "Full"
InstType "Minimal"

# Installer sections
Section -Main SectionMain
    SetShellVarContext all
    SetOverwrite on
    # Files
    SetOutPath $INSTDIR
    File /r ${WEKA_FILES}\*
    # files from template directory have to be listed separately
    File ${WEKA_TEMPLATES}\RunWeka.bat
    File ${WEKA_TEMPLATES}\RunWeka.ini
    File ${WEKA_TEMPLATES}\RunWeka.class
    # Links in App directory (to get the working directory of the links correct!)
    SetOutPath $INSTDIR
#    CreateShortcut "$INSTDIR\${WEKA_LINK_PREFIX}.lnk" "$INSTDIR\RunWeka.bat" "default" $INSTDIR\Weka.ico
#    CreateShortcut "$INSTDIR\${WEKA_LINK_PREFIX} (with console).lnk" "$INSTDIR\RunWeka.bat" "console" $INSTDIR\Weka.ico
    CreateShortcut "$INSTDIR\${WEKA_LINK_PREFIX}.lnk" "$INSTDIR\${WEKA_JRE}\bin\javaw.exe" '-classpath "$INSTDIR" RunWeka -i "$INSTDIR\RunWeka.ini" -w "$INSTDIR\weka.jar" -jre-path "$INSTDIR\${WEKA_JRE}"' $INSTDIR\Weka.ico
    CreateShortcut "$INSTDIR\${WEKA_LINK_PREFIX} (with console).lnk" "$INSTDIR\${WEKA_JRE}\bin\java.exe" '-classpath "$INSTDIR" RunWeka -i "$INSTDIR\RunWeka.ini" -w "$INSTDIR\weka.jar" -c console -jre-path "$INSTDIR\${WEKA_JRE}"' $INSTDIR\Weka.ico
    WriteRegStr HKLM "${REGKEY}\Components" Main 1
SectionEnd

# associate .arff with WEKA
Section "Associate Files" SectionAssociations
    SectionIn 1
    SetShellVarContext all
    # ARFF
    WriteRegStr HKCR ".arff" "" "ARFFDataFile"
    WriteRegStr HKCR "ARFFDataFile" "" "ARFF Data File"
    WriteRegStr HKCR "ARFFDataFile\DefaultIcon" "" "$INSTDIR\weka.ico"
    WriteRegStr HKCR "ARFFDataFile\shell\open\command" "" '"$INSTDIR\${WEKA_JRE}\bin\javaw.exe" "-classpath" "$INSTDIR" "RunWeka" "-i" "$INSTDIR\RunWeka.ini" "-w" "$INSTDIR\weka.jar" "-c" "explorer" "-jre-path" "$INSTDIR\${WEKA_JRE}" "%1"'
    # XRFF
    WriteRegStr HKCR ".xrff" "" "XRFFDataFile"
    WriteRegStr HKCR "XRFFDataFile" "" "XRFF Data File"
    WriteRegStr HKCR "XRFFDataFile\DefaultIcon" "" "$INSTDIR\weka.ico"
    WriteRegStr HKCR "XRFFDataFile\shell\open\command" "" '"$INSTDIR\${WEKA_JRE}\bin\javaw.exe" "-classpath" "$INSTDIR" "RunWeka" "-i" "$INSTDIR\RunWeka.ini" "-w" "$INSTDIR\weka.jar" "-c" "explorer" "-jre-path" "$INSTDIR\${WEKA_JRE}" "%1"'
    # kf
    WriteRegStr HKCR ".kf" "" "KFFlowFile"
    WriteRegStr HKCR "KFFlowFile" "" "KF Flow File"
    WriteRegStr HKCR "KFFlowFile\DefaultIcon" "" "$INSTDIR\weka.ico"
    WriteRegStr HKCR "KFFlowFile\shell\open\command" "" '"$INSTDIR\${WEKA_JRE}\bin\javaw.exe" "-classpath" "$INSTDIR" "RunWeka" "-i" "$INSTDIR\RunWeka.ini" "-w" "$INSTDIR\weka.jar" "-c" "knowledgeFlow" "-jre-path" "$INSTDIR\${WEKA_JRE}" "%1"'
    # kfml
    WriteRegStr HKCR ".kfml" "" "KFMLFlowFile"
    WriteRegStr HKCR "KFMLFlowFile" "" "KFML Flow File"
    WriteRegStr HKCR "KFMLFlowFile\DefaultIcon" "" "$INSTDIR\weka.ico"
    WriteRegStr HKCR "KFMLFlowFile\shell\open\command" "" '"$INSTDIR\${WEKA_JRE}\bin\javaw.exe" "-classpath" "$INSTDIR" "RunWeka" "-i" "$INSTDIR\RunWeka.ini" "-w" "$INSTDIR\weka.jar" "-c" "knowledgeFlow" "-jre-path" "$INSTDIR\${WEKA_JRE}" "%1"'

Call RefreshShellIcons
SectionEnd

# Start: JRE
# install JRE
Section "Install JRE" SectionJRE
    SectionIn 1
    
    # extract JRE to "jre_setup.exe"
    File /oname=$INSTDIR\${WEKA_JRE_TEMP} "${WEKA_JRE}"
    SetOutPath $INSTDIR
    
    # write batch file
    FileOpen $9 "${WEKA_JRE_INSTALL}" w
    FileWrite $9 "${WEKA_JRE_TEMP}$\r$\n"
    FileWrite $9 "del ${WEKA_JRE_TEMP}$\r$\n"
    FileClose $9

    # execute batch file    
    ExecWait "${WEKA_JRE_INSTALL}"
    
    # delete temp files
    Delete "$INSTDIR\${WEKA_JRE_INSTALL}"
    Delete "$INSTDIR\${WEKA_JRE_TEMP}"
SectionEnd
# End: JRE

Section -post SectionPost
    SetShellVarContext all
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    WriteUninstaller $INSTDIR\uninstall.exe

    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Documentation.lnk" $INSTDIR\documentation.html
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${WEKA_LINK_PREFIX} (with console).lnk" "$INSTDIR\${WEKA_LINK_PREFIX} (with console).lnk" "" $INSTDIR\Weka.ico
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${WEKA_LINK_PREFIX}.lnk" "$INSTDIR\${WEKA_LINK_PREFIX}.lnk" "" $INSTDIR\Weka.ico
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk" $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_END

    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    SetShellVarContext all
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o un.Main UNSEC0000
    SetShellVarContext all
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${WEKA_LINK_PREFIX}.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${WEKA_LINK_PREFIX} (with console).lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Documentation.lnk"
    Delete /REBOOTOK "$INSTDIR\RunWeka.class"
    Delete /REBOOTOK "$INSTDIR\RunWeka.ini"
    Delete /REBOOTOK "$INSTDIR\RunWeka.bat"
    RmDir /r /REBOOTOK $INSTDIR
    DeleteRegValue HKLM "${REGKEY}\Components" Main
    # ARFF
    DeleteRegKey HKCR ".arff"
    DeleteRegKey HKCR "ARFFDataFile"
    # XRFF
    DeleteRegKey HKCR ".xrff"
    DeleteRegKey HKCR "XRFFDataFile"
SectionEnd

Section un.post UNSEC0001
    SetShellVarContext all
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk"
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    RmDir /REBOOTOK $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOOTOK $INSTDIR
SectionEnd

# Section overview
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionAssociations} "Associates the .arff and .xrff files with the Weka Explorer."
  # Start: JRE
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionJRE} "Installs the Java Runtime Environment (JRE)."
  # End: JRE
!insertmacro MUI_FUNCTION_DESCRIPTION_END

# Installer functions
Function .onInit
    InitPluginsDir
FunctionEnd

# Uninstaller functions
Function un.onInit
    SetShellVarContext all
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    ReadRegStr $StartMenuGroup HKLM "${REGKEY}" StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd

Function RefreshShellIcons
  !define SHCNE_ASSOCCHANGED 0x08000000
  !define SHCNF_IDLIST 0
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

# launches program
Function LaunchProgram
  ExecShell "" "$INSTDIR\${WEKA_LINK_PREFIX}.lnk" "" SW_SHOWNORMAL
FunctionEnd
