/**
 * 
 * Initilize TinyMCE editor with all required options
 */

// TinyMCE DomQuery variable
let dom = tinymce.dom.DomQuery

// Invisible space constant
const ZERO_SPACE = '&#8203;'

$(document).ready(function () {
  //hide footer
  $('footer.footer').hide()

  //attach whole body inside a placeholder div
  $('body').html(`<div id="raje_root">${$('body').html()}</div>`)

  tinymce.init({

    // Select the element to wrap
    selector: '#raje_root',

    // Set the styles of the content wrapped inside the element
    content_css: ['css/bootstrap.min.css', 'css/rash.css'],

    // Set plugins
    plugins: "fullscreen link codesample inline_code inline_quote section table noneditable",

    // Remove menubar
    menubar: false,

    // Custom toolbar
    toolbar: 'undo redo bold italic link codesample superscript subscript inline_code | blockquote table figure | section',

    // Setup full screen on init
    setup: function (editor) {

      editor.on('init', function (e) {
        editor.execCommand('mceFullScreen');
      });
    },

    // Set default target
    default_link_target: "_blank",

    // Prepend protocol if the link starts with www
    link_assume_external_targets: true,

    // Hide target list
    target_list: false,

    // Hide title
    link_title: false,

    // Set formats
    formats: {
      inline_code: {
        inline: 'code'
      },
      inline_quote: {
        inline: 'q'
      },

      sections: {
        block: 'section'
      },
      heading: {
        block: 'h1'
      }
    }
  });
})

/**
 * Inline code plugin RAJE
 */
tinymce.PluginManager.add('inline_code', function (editor, url) {

  // Add a button that opens a window
  editor.addButton('inline_code', {
    text: 'inline_code',
    icon: false,
    tooltip: 'Inline code',

    // Button behaviour
    onclick: function () {
      Rajemce.inline.code.handle()
    }
  });
});

/**
 *  Inline quote plugin RAJE
 */
tinymce.PluginManager.add('inline_quote', function (editor, url) {

  // Add a button that handle the inline element
  editor.addButton('inline_quote', {
    text: 'inline_quote',
    icon: false,
    tooltip: 'Inline quote',

    // Button behaviour
    onclick: function () {
      Rajemce.inline.quote.handle()
    }
  });
});

/**
 * RASH section plugin RAJE
 */
tinymce.PluginManager.add('section', function (editor, url) {

  editor.addButton('section', {
    type: 'menubutton',
    text: 'Headings',
    icons: false,

    // Sections sub menu
    menu: [{
      text: 'Abstract',
      onclick: function () {}
    }, {
      text: 'Acknowledgements',
      onclick: function () {}
    }, {
      text: 'Heading 1.',
      onclick: function () {
        Rajemce.section.insert(1)
      }
    }, {
      text: 'Heading 1.1.',
      onclick: function () {
        Rajemce.section.insertRaw(2)
      }
    }]
  })
})



/**
 * RajeMCE class
 * It contains every custom functions to attach to plugins
 */
Rajemce = {

  // Inline elements
  inline: {

    code: {
      /**
       * Insert or exit from inline code element
       */
      handle: function () {

        let name = tinymce.activeEditor.selection.getNode().nodeName

        if (name == 'CODE')
          tinymce.activeEditor.formatter.remove('inline_code')

        else
          tinymce.activeEditor.formatter.apply('inline_code')
      }
    },

    quote: {
      /**
       * Insert or exit from inline quote element
       */
      handle: function () {

        let name = tinymce.activeEditor.selection.getNode().nodeName

        if (name == 'Q')
          tinymce.activeEditor.formatter.remove('inline_quote')

        else
          tinymce.activeEditor.formatter.apply('inline_quote')
      }
    }
  },

  // Section functions
  section: {
    insertRaw: function (level) {

      // Reference of the selected element
      let selectedElement = tinymce.activeEditor.selection.getNode()

      // HTML string to insert
      let text = ''
      let newSection = `<section><h1>${ZERO_SPACE}`

      // Get deepness of the current section and add section closures 
      let deepness = dom(selectedElement).parentsUntil('body#tinymce').length - level + 1

      if (deepness == 0)
        newSection += '</section>'

      // Block all non-permitted behaviours
      if (deepness >= 0) {

        while (deepness > 0) {
          text += '</section>'
          deepness--
        }

        // Full text to insert with p text
        newSection = text + newSection + `${dom(selectedElement).text()}</h1>`

        // Delete preceding element
        dom(selectedElement).remove()

        // Close current section and open the new one
        tinymce.activeEditor.execCommand('mceInsertRawHtml', false, newSection)

        // It doesn't work
        headingDimension()

        tinymce.activeEditor.execCommand('mceRepaint')

        console.log(dom('section'))
      }
    },

    insert: function(){

      // Select current node
      let selectedElement = tinymce.activeEditor.selection.getNode()
      let newSection = dom(`<section><h1>${dom(selectedElement).html()}</h1><p></p></section>`)

      // Attach the element to the parent section
      dom(selectedElement).parent('section').after(newSection)

      // Remove the selected section
      dom(selectedElement).remove()

      // Add the change to the undo manager
      tinymce.activeEditor.undoManager.add()
    }
  }
}

// Modularize rash

function headingDimension() {
  /* Heading dimensions */
  $("h1").each(function () {
    var counter = 0;
    $(this).parents("section").each(function () {
      if ($(this).children("h1,h2,h3,h4,h5,h6").length > 0) {
        counter++;
      }
    });
    $(this).replaceWith("<h" + counter + ">" + $(this).html() + "</h" + counter + ">")
  });
  /* /END Heading dimensions */
}