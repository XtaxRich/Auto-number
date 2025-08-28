@echo off
chcp 65001 >nul
echo ====================================
echo     视频文件自动重命名工具
echo ====================================
echo.

set /p "targetPath=请输入要监控的文件夹路径: "
set /p "chapter=请输入章数: "
set /p "section=请输入节数: "

echo.
echo 开始监控文件夹: %targetPath%
echo 章节设置: 第%chapter%章第%section%节
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0video_renamer.ps1" -TargetPath "%targetPath%" -Chapter %chapter% -Section %section%

echo.
echo 按任意键退出...
pause >nul