function getMixId(mixlink) {
    let mixId = mixlink.replace(/\./g, '_').replace(/\//g, '_');
    return mixId;
}

function getSamplesLink(mixLink) {
    return mixLink.replace('/mixes/', '/samples/');
}

document.addEventListener('DOMContentLoaded', function () {
    browser = navigator.userAgent.toLowerCase();

    u("img.preview-icon").on('mouseenter', function (e) {
        let mixLink = u(this).parent('div.mix-holder').find('a.amixlink').attr('href');
        console.log("mixlink: "+mixLink);
        let mixId = getMixId(mixLink);
        let samplesLink = getSamplesLink(mixLink);

        u("body").append(
            '<audio id="' + mixId + '" autoplay="autoplay">' +
            '<source src="' + samplesLink + '"' +
            '</audio>'
        )
    });

    u("img.preview-icon").on('mouseleave', function (e) {
        let mixLink = u(this).parent('div.mix-holder').find('a.amixlink').attr('href');
        let mixId = getMixId(mixLink);
        u("#" + mixId).remove();
    });
});