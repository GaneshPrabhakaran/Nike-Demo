var Cuke = (function() {
    var embedBase = 'embed table ', embedRaw = 'raw', embedImage = 'image', message = 'message', category = 'category', colspan = 'td[colspan]';
    var expandedClass = 'expanded', collapsedClass = 'collapsed';
    var redClass = 'red', yellowClass = 'yellow', greenClass = 'green';
    var generateHead = function(cssClass, $destination, text) {
        $('<th />', { 'class': cssClass, text: text }).appendTo($destination);
    };
    var generateCell = function(cssClass, $destination, parent) {
        console.log(parent);
        var $res = $('<td />', {'class': cssClass}).appendTo($destination);
        if(parent) { $res.append($(parent).children('a')); }
    };
    var toElement = function(element) { return typeof(element) === 'string' ? $('#' + element) : $(element); };

    return {
        fixupContents: function($headers, $misc) {
            $headers.each(function() {
                var $header = $(this);
                var state = 'passed';
                if($header.hasClass(redClass)) { state = 'failed'; }
                if($header.hasClass(yellowClass)) { state = 'skipped'; }
                $header.siblings('.comment,.tags-container').addClass(state).prependTo($header.siblings('.scenario-details'));
            });
            $misc.each(function() { $(this).prependTo($(this).parent()); });
        },
        fixupExamples: function($table) {
            if ($table.is(':empty')) { return $table.remove(); }
            var hasMessages = $table.find('td.' + message).length;
            var hasCategories = $table.find('td.' + category).length;
            var hasImages = $table.parent().children('.embed.image').length;
            var $embeds = $table.parent().children('.embed');
            var start = 0;
            $table.find(colspan).attr('colspan', 6 + (hasMessages ? 1 : 0) + (hasCategories ? 1 : 0) + (hasImages ? 2 : 0)).parent().addClass('stack');
            var $header = $table.find('tr:first-child');
            if (hasMessages) { generateHead(message, $header, message); }
            if (hasCategories) { generateHead(category, $header, category); }
            generateHead(embedBase + embedRaw, $header);
            generateHead(embedBase + embedRaw, $header);
            if (hasImages) {
                generateHead(embedBase + embedImage, $header);
                generateHead(embedBase + embedImage, $header);
            }
            $table.find('tr:not(:first-child,.stack)').each(function() {
                var $row = $(this);
                if (hasMessages && !$row.children('.' + message).length) { generateCell(message, $row); }
                if (hasCategories && !$row.children('.' + category).length) { generateCell(category, $row); }
                generateCell(embedBase + embedRaw, $row, $embeds[start]);
                generateCell(embedBase + embedRaw, $row, $embeds[start + 1]);
                start += 2;
                if ($($embeds[start]).hasClass('image')) {
                    generateCell(embedBase + embedImage, $row, $embeds[start]);
                    generateCell(embedBase + embedImage, $row, $embeds[start + 1]);
                    start += 2;
                }
                else if (hasImages) {
                    generateCell(embedBase + embedImage, $row);
                    generateCell(embedBase + embedImage, $row);
                }
            });
            $embeds.remove();
            $table.find('a').attr({'target': '_blank', 'data-for': null});
        },
        red: function(element) { toElement(element).removeClass(greenClass).removeClass(yellowClass).addClass(redClass); },
        yellow: function(element) { toElement(element).removeClass(greenClass).addClass(yellowClass); },
        loadFailed: function(element) { $(element).addClass('load-failed'); },
        toggle: function(element) { return $(element).toggleClass(collapsedClass).toggleClass(expandedClass); },
        expand: function(element) { return $(element).removeClass(collapsedClass).addClass(expandedClass); },
        collapse: function(element) { return $(element).addClass(collapsedClass).removeClass(expandedClass); },
        filter: function(value) {
            if (value === 'all') { return $('.feature,.scenario').show(); }
            $('.feature').each(function() {
                var $feature = $(this);
                var $scenarios = $feature.children('.scenario');
                if ($feature.children('.tags-container').children('.tag').text().split('@').indexOf(value) !== -1) {
                    $feature.show();
                    $scenarios.show();
                }
                else {
                    $scenarios.each(function() {
                        var $scenario = $(this);
                        if ($scenario.find('.tag').text().split('@').indexOf(value) !== -1) { $scenario.show(); }
                        else { $scenario.hide(); }
                    });
                    if ($scenarios.filter(':visible').length !== 0) { $feature.show(); }
                    else { $feature.hide(); }
                }
            });
        }
    };
})();


$(document).ready(function() {
    var duration = 250;
    var scenarioDetails = '.scenario-details';

    $('img').error(function() { Cuke.loadFailed(this); });

    var $filter = $('#tag-filter');
    var $scenarios = $('.scenario-header');

    Cuke.fixupContents($scenarios, $('.feature').children('h2,.tags-container').add($('.background').children('h3')));
    $('table.outline').each(function() { Cuke.fixupExamples($(this)); });

    var $embeds = $('.embed:not(.table)');
    var $allDetails = $scenarios.siblings(scenarioDetails);

    var tags = $('.tag').text().split('@').sort();
    for (var i = 1; i < tags.length; i++) {
        if ($filter.children('[value="' + tags[i] + '"]').length === 0) {
            $filter.append($('<option/>', { text: '@' + tags[i], value: tags[i] }));
        }
    }
    $filter.change(function() { Cuke.filter($(this).val()); });

    $scenarios.click(function() {
        var $scenario = $(this);
        $scenario.siblings(scenarioDetails).slideToggle(250);
        Cuke.toggle($scenario.parent());
    });
    $('#expander').click(function() {
        $allDetails.slideDown(duration);
        Cuke.expand($scenarios.parent());
    });
    $('#collapser').click(function() {
        $allDetails.slideUp(duration);
        Cuke.collapse($scenarios.parent());
    });
    $('.code-toggle').click(function() {
        Cuke.toggle(this).siblings('.code-container').slideToggle(duration);
    });
    $('#failure-expander').click(function() {
        var $failures = $scenarios.filter('.red');
        $failures.siblings(scenarioDetails).slideDown(duration);
        Cuke.expand($failures.parent());
    });
    $embeds.filter('.image').children('a').click(function(e) {
        if (e.button === 0) {
            var $a = $(this);
            var $for = $($a.data('for'));
            if($for.children('img').hasClass('load-failed')) { return true; }
            $($a.data('for')).slideToggle(duration);
            return false;
        }
    });
    $embeds.filter('.raw').children('a').click(function(e) {
        if (e.button === 0) {
            var $a = $(this);
            var $pre = $($a.data('for')).children('pre');
            var uri = $a.attr('href');
            $.ajax(uri)
                .fail(function() { window.open(uri, '_blank'); })
                .done(function(html) { $pre.html(html).parent().slideToggle(250); });
            return false;
        }
    });
    var $outlines = $('.scenario.outline').find('.scenario-header');
    $outlines.filter('.yellow').parent().find('.example').each(function() {
        var $example = $(this);
        if ($example.find('.step.undefined').length > 0) { Cuke.yellow($example.children('h3')); }
    });
    $outlines.find('.red').parent().find('.example').each(function() {
        var $example = $(this);
        if ($example.find('.step.failed').length > 0) { Cuke.red($example.children('h3')); }
    });
});