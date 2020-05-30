JsOsaDAS1.001.00bplist00�Vscript_Qvar app = Application.currentApplication()
app.includeStandardAdditions = true

var version = 'v' + app.doShellScript(`defaults read '${app.pathTo(this)}/Contents/Info.plist' CFBundleShortVersionString`)
var latestVersion = app.doShellScript(`curl -s "https://api.github.com/repos/godly-devotion/charge-limiter/releases/latest" | awk -F '"' '/tag_name/{print $4}'`)
var url = `https://github.com/godly-devotion/charge-limiter/releases/latest`

if (latestVersion && version !== latestVersion) {
	if (app.displayAlert(`A new version of charge-limiter is available!`, {
		message: `${latestVersion} is now available-you have ${version}. Would you like to get the update?`,
		as: 'critical',
		buttons: ['Skip', 'Get Update'],
		defaultButton: 'Get Update'
	}).buttonReturned === 'Get Update') {
		app.doShellScript(`open ${url}`)
	}
}

var parentPath = app.pathTo(this) + '/Contents/Resources';

app.doShellScript(`chmod +x '${parentPath}/smcutil'`)
var chargeLevel = app.doShellScript(`'${parentPath}/smcutil' -r BCLM`)

var response = app.displayDialog(`This utility allows you to set the maximum charge level by modifying the SMC.\n\nThe current max charge level is: ${chargeLevel}%\n\nCharge Limit (40-100, default is 100):`, {
	withTitle: `charge-limiter ${version}`,
    defaultAnswer: '',
    buttons: ['Close', 'Set Charge Limit'],
    defaultButton: 'Set Charge Limit',
	cancelButton: 'Close'
})

if (isNaN(response.textReturned)) {
    app.displayDialog('Please enter a number.', {
		buttons: ['Cancel'],
		defaultButton: 'Cancel'
	})
}

var value = Number(response.textReturned)
if (value < 40 || value > 100 ) {
	app.displayDialog('Please enter a number from 40-100.', {
		buttons: ['Cancel'],
		defaultButton: 'Cancel'
	})
}

try {
	var hexValue = app.doShellScript(`python -c 'print "%02X" % ${value}'`)
	app.doShellScript(`sudo '${parentPath}/smcutil' -w BCLM ${hexValue}`, { administratorPrivileges: true })
	app.displayDialog(`Success!`, { buttons: ['OK'] })
}
catch (e) {
	app.displayDialog(`There was a problem setting the charge limit. Please make sure you have administrator privileges.`, { buttons: ['OK'] })
}                              g jscr  ��ޭ