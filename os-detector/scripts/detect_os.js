const os = require('os');

const platform = os.platform();
const release = os.release();

let osName = 'Unknown';
if (platform === 'win32') {
    osName = 'Windows';
} else if (platform === 'darwin') {
    osName = 'macOS';
} else if (platform === 'linux') {
    osName = 'Linux';
}

console.log(JSON.stringify({
    os: osName,
    platform: platform,
    release: release
}, null, 2));
