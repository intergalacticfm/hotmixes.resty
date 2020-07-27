var preview;
function getMixId(mixlink) {
    let mixId = mixlink.replace(/\./g, '_').replace(/\//g, '_');
    return mixId;
}

function getSamplesLink(mixLink) {
    return mixLink.replace('/mixes/', '/samples/');
}

document.addEventListener('DOMContentLoaded', function () {
    browser = navigator.userAgent.toLowerCase();

    u("button.preview").on(['mousedown', 'touchstart'], function (e) {
        let samplesLink = getSamplesLink(u(this).siblings('a.amixlink').attr('href'));
        preview = new Howl({
            src: [samplesLink],
            autoplay: true,
            volume: 0
        });

        preview.play();
        preview.fade(0, 1, 5000);

    });

    u("button.preview").on(['mouseup', 'touchend'], function (e) {
        preview.stop();
    });
});