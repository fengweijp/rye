assert = chai.assert

$ = Rye

list_items = -> $('.list li')

suite 'Querying', ->

    test 'ID query', ->
        el = $('#hello')
        assert.lengthOf el, 1
        assert el.length is 1, "Has one element"

        el = $('#no-exists')
        assert.lengthOf el, 0, "It has no elements"

    test 'class query', ->
        el = $('.a')
        assert.lengthOf el, 1, "Has one element"

    test 'tag query', ->
        el = $('section')
        assert.lengthOf el, 1, "Has one element"
        assert el.get(0).tagName is 'SECTION', "Tag matches"

    test 'complex query', ->
        el = $('section#test .list .b')
        assert.lengthOf el, 1, "It has one element"

    test 'multiple results', ->
        el = $('#test li')
        assert.lengthOf el, 3, "It has 3 elements"

    test 'matches error', ->
        el = $()
        el.elements = [{}]
        el._update()

        assert.lengthOf el.filter(), 0, "matches filter only elements"

    test 'matches fallback', ->
        # this test is really dont cool
        util = $.require('util')

        parent = document.createElement('div')
        children_foo = document.createElement('div')
        children_foo.className = 'foo'
        children = document.createElement('div')
        parent.appendChild children_foo
        parent.appendChild children
        el = $(parent)

        prefix = util.prefix
        util.prefix = -> return false

        filter_div = el.filter('div')
        filter_foo = el.children().filter('.foo')

        util.prefix = prefix # restore prefix

        assert.deepEqual filter_div.elements, [parent], "Remains the parent"
        assert.deepEqual filter_foo.elements, [children_foo], "Remains the parent"
        
suite 'Traversal methods', ->
    test 'find', ->
        all = $('*')
        list = all.find('.list li')
        assert.deepEqual list.get(), list_items().get(), "Gets the list items"

    test 'find in one', ->
        doc = $(document)
        list = doc.find('.list li')
        assert.deepEqual list.get(), list_items().get(), "Gets the list items"

    test 'filter', ->
        all = $('*')
        list = all.filter('.list li')
        assert.deepEqual list.get(), list_items().get(), "Filter the list items"

        nothing = all.filter('.nothing-with-this')
        assert.equal nothing.length, 0, "Filter should returns nothing"

        assert.deepEqual all, $('*'), "Doesnt affect the original"

    test 'is', ->
        doc = $(document)
        assert.isTrue doc.is(document), "Document is document"

        list = list_items()
        assert.isTrue list.is('li'), "Filter the list items"

        all = $('*')
        assert.isTrue all.is(list_items()), "Filter the list items with Rye instance"

    test 'add multiple (Rye)', ->
        list = list_items()
        list2 = list_items()
        list3 = list.add(list2)
        assert list3.length is 3, "List length shouldn't change"
        assert.deepEqual list3.pluck('className'), ['a', 'b', 'c'], "Elements are the same"

    test 'add multiple (Array)', ->
        list = list_items()
        list2 = list_items().get()
        list3 = list.add(list2)
        assert list3.length is 3, "List length shouldn't change"
        assert.deepEqual list3.pluck('className'), ['a', 'b', 'c'], "Elements are the same"

    test 'add single item', ->
        list = list_items()
        div = document.createElement('div')
        list3 = list.add(div)
        assert list3.length is 4, "Has four items"
        assert.deepEqual list3.pluck('className'), ['a', 'b', 'c', ''], "Classes match"
        assert list3.get(3) is div, "Element was appended to the list"

    test 'add invalid item', ->
        list = list_items()
        list3 = list.add('bacon')
        assert list3.length is 3, "Length didn't change"
        assert.deepEqual list3.pluck('className'), ['a', 'b', 'c'], "Classes match"

    test 'pluck node', ->
        list = list_items()
        first = $(list.get(0))
        second = $(first.pluckNode('nextSibling'))
        assert.equal second.get(0), list.get(1), "Walks to second element"

    test 'pluck', ->
        obj = $()
        obj.elements[0] = fizz: 'buzz'
        obj._update()
        assert.deepEqual obj.pluck('fizz'), ['buzz'], "Plucks elements properties"

    test 'next', ->
        el = $('.a').next()
        assert el.length is 1, "One element found"
        assert el.get(0).className is 'b', "Next element is .b"

    test 'prev', ->
        el = $('.c').prev()
        assert el.length is 1, "One element found"
        assert el.get(0).className is 'b', "Previous element is .b"

    test 'first', ->
        first = list_items().first()
        assert first.length is 1, "One element found"
        assert first.get(0).className is 'a', "first() is .a"

    test 'last', ->
        last = list_items().last()
        assert last.length is 1, "One element found"
        assert last.get(0).className is 'c', "last() is .c"

    test 'siblings', ->
        list = list_items()
        siblings = list.eq(1).siblings()
        assert siblings.length is 2, "Two siblings"
        assert.deepEqual siblings.get().map((el) -> el.className), ['a', 'c']

    test 'parent', ->
        el = $('.a').parent()
        assert el.length is 1, "One element found"
        assert el.get(0).className is 'list', "Parent is .list"

    test 'parents', ->
        els = $('.a').parents()

        assert.isTrue els.is('ul'), "Ul element found"
        assert.isTrue els.is('body'), "Body always found"

    test 'closest', ->
        el = $('.a')
        closest = el.closest('ul')
        assert.lengthOf closest, 1
        assert.equal closest.get(0).className, 'list'

        el = $('.a')
        closest = el.closest('.a')
        assert.lengthOf closest, 1
        assert.equal closest.get(0).className, 'a'

        closest = el.closest('section#test')
        assert.lengthOf closest, 1
        assert.equal closest.get(0).id, 'test'

        closest = el.closest('html')
        assert.lengthOf closest, 1
        assert.equal closest.get(0), document.documentElement

        closest = el.closest('bacon')
        assert.lengthOf closest, 0

    test 'children', ->
        list = $('.list').children()

        assert.deepEqual list.elements, list_items().elements, "Ul element found"


