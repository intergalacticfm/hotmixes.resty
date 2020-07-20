function getMixId(e) {
    let mixId = getMixLink(e).replace(/\./g, '_').replace(/\//g, '_');
    return mixId;
}

function getMixLink(e) {
    let mixLink = e.target.getAttribute("href");
    return mixLink;
}

function getSamplesLink(mixLink) {
    return mixLink.replace('/mixes/', '/samples/');
}

document.addEventListener('DOMContentLoaded', function () {
    browser = navigator.userAgent.toLowerCase();

    u("a.amixlink").on('mouseenter', function (e) {
        let mixLink = getMixLink(e);
        let mixId = getMixId(e);
        let samplesLink = getSamplesLink(mixLink);

        u("body").append(
            '<audio id="' + mixId + '" autoplay="autoplay">' +
            '<source src="' + samplesLink + '"' +
            '</audio>'
        )
    });

    u("a.amixlink").on('mouseleave', function (e) {
        let mixId = getMixId(e);
        u("#" + mixId).remove();
    });
});