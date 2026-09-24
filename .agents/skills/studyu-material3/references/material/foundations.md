# Material 3 · Foundations

<!-- Source: m3.material.io · foundations.md · updated 2026-07-17T05:06:20.337Z · CC-BY 4.0 (Google) -->

## Foundations

> Foundations inform the basis of any great user interface, from accessibility standards to essential patterns for layout and interaction.



<!-- section: Tab 1 -->

_footer: Accessible design enables users with diverse abilities to navigate, understand, and enjoy a UI._
_link: https://m3.material.io/foundations/overview/principles_

_footer: UX writing and information design make UIs easy to use._
_link: https://m3.material.io/foundations/content-design/overview_

_footer: M3 makes brand expression in an interface simpler and more beautiful than ever before._
_link: https://m3.material.io/foundations/customization_

_footer: Tokens store style values like colors and fonts so the same values can be used across designs, code, tools, and platforms._
_link: https://m3.material.io/foundations/design-tokens/overview_

_footer: States are visual indicators used to communicate the status of a component or interactive element._
_link: https://m3.material.io/foundations/interaction/states/overview_

_footer: Layout is the visual arrangement of elements on the screen._
_link: https://m3.material.io/foundations/layout/understanding-layout/overview_

_footer: Get to know the key terms and concepts behind Material, from A to Z._
_link: https://m3.material.io/foundations/glossary_

_footer: Building for everyone with everyone_
_link: https://m3.material.io/foundations/building-for-all/user-needs_

---

<!-- Source: m3.material.io · foundations_overview · updated 2026-07-17T05:27:26.725Z · CC-BY 4.0 (Google) -->

## Overview

> Accessible design enables users with diverse abilities to navigate, understand, and enjoy a UI



<!-- section: Principles -->

## Accessibility & Material Design

**Accessibility by default** is a core design value for Material. Material's accessibility requirements and goals are documented across component pages and guidelines. Understanding your product’s accessibility can enhance usability for all users, including those with low vision, blindness, hearing impairments, cognitive impairments, motor impairments, or situational disabilities (such as a broken arm).

Accessibility standards are built into Material components, providing a foundation for inclusive product design. Anticipating a wide range of human experiences and disabilities prevents costly redesigns, reduces tech and design debt, and conserves resources upfront.

## Principles for accessible design

The following principles for accessible design are approaches that can help **anticipate, include, and respond to the needs of individuals**. They're considerations for design, development, collaboration, and co-creation that encourage inclusive and equitable outcomes.

### Honor individuals

Universal default experiences rarely meet everyone’s needs. Introducing customizable features in a default experience allows room for individual adaptation. Honoring the shifting needs of any person can mean giving more freedom to choose things for themselves.

Because a person's experience throughout their day, or year, or life can continue to change, it helps to support varying preferences and choices that allow individuals to address how their changing conditions, individual knowledge, and varying needs are met.

_altText: silhouette of person's head made out of colorful liquid_

### Learn before, not after

Before defining solutions, invest time in understanding the needs of users with a wide range of abilities and life experiences. Formal and informal research can open new ways of thinking, reduce biases, and encourage creative ways to make access available, especially to those who fall outside prevailing norms.

Accessible design processes anticipate as many potential product or experience outcomes as possible upfront. When user problems do arise, exploring the unanticipated outcomes can become a research foundation for learning, adapting, and recovering thoughtfully.

_altText: cube floating above a circular hole_

### Requirements as a starting point

The minimum requirements established by [WCAG](https://www.w3.org/WAI/standards-guidelines/wcag/) support specific human needs. However, these requirements can produce creative solutions with broad benefits.

History has shown that features originating from responses to specific access needs (dark mode, text-to-speech, speech-to-text) are a result of creative problem-solving within specified constraints. Seeing the requirements as opportunities, rather than constraints, has been shown to lead to solutions that ultimately serve many.

_altText: foam-like material sculpted into a puzzle piece resembling a standing human_

<!-- section: Assistive technology -->

## Assistive technology

Assistive technology helps increase, maintain, or improve the functional capabilities of individuals with disabilities. People can live more independently by engaging with technology through devices like keyboards, screen readers, and braille displays, as well as tracking input, magnifiers, and voice input.

_footer: Icons are one example of interactive elements that require an understanding of different input methods and user needs. In this example the target area of the icon is identified to show how the expanded icon perimeter makes interacting with an action more accessible._
_altText: Examples of icons with target sizes indicated beyond the actual size of the icon_

### Common forms of assistive technologies

#### **Keyboard**

Hardware or software directional controllers such as keyboards, a D-pad, or trackball allow users to jump from selection to selection in a linear fashion.

#### **Screen readers**

A screen reader is a software program that uses either a braille display or reads text aloud, such as Google’s screen reader, TalkBack. People with vision impairments, experiencing difficulty reading, or who temporarily can’t read might use a screen reader. Screen readers verbalize visible content and read it aloud. Paragraph and button text, as well as hidden content like alternative text for icons and headings, are identified by the program. Content can be labeled to optimize the experience for those who use screen readers or experience a text-only version of your UI.

#### **Switch input**

Switches scan the items on your screen, highlighting each item in turn, until you make a selection. Switch Access lets you interact with your Android device using one or more switches instead of the touchscreen.

---

<!-- Source: m3.material.io · foundations_designing · updated 2026-07-17T05:01:47.617Z · CC-BY 4.0 (Google) -->

## Designing

> Implement intuitive, accessible layouts, considering structure, color, and flow



<!-- section: Overview -->

Designing and implementing accessible product experiences involve a range of considerations. The framework Material uses draws on WCAG standards and industry best practices.

The three stages described in these tabs help **translate a visual UI into a text-based, linear user experience that maps to code**. Color and contrast also support accessible navigation.

### Accessibility markup

Accessibility markup is an integral part of creating documentation for design specs.

_footer: 1. Switch in the on state with visible focus 2. Switch in the off state with visible focus_
_altText: Diagram of switches showing the Tab key changing the focus to the second switch and Space/Enter corresponding to changing the state of the switch._

### Implementing accessibility

By using standard platform controls and semantic HTML (on the web), apps automatically contain the markup and code needed to work well with a platform’s assistive technology. Meeting each platform's accessibility standards and supporting its assistive technology (including shortcuts and structure) gives users an efficient experience.

_footer: Use native elements, such as the standard platform dialog_
_altText: A dialog in a UI screen requesting user confirmation to discard calendar event_

_footer: Be wary of using non-standard elements, such as a non-standard platform dialog to perform a standard dialog task. It requires extra testing to work well with assistive technology._
_altText: A banner requesting user confirmation to discard a calendar event_

<!-- section: Color contrast -->

## Color & contrast

Color and contrast can be used to help users see and interpret your app’s content, interact with the right elements, and understand actions.

Color can help communicate mood, tone, and critical information. Primary, secondary, and accent colors can be selected to support usability. Sufficient color contrast between elements can help users with low vision see and use your app.

_altText: two colors applied to button container and UI surface with contrast that passes 3:1 minimum_

### Contrast ratios

Color contrast is important for users to distinguish various text and non-text elements. Higher contrast makes the imagery easier to see, while low-contrast images may be difficult for some users to differentiate in bright or low light conditions, such as on a very sunny day or at night.

Contrast ratios represent how different one color is from another color, commonly written as 1:1 or 21:1. The greater the difference is between the two numbers in the ratio, the greater the difference in relative luminance between the colors. The contrast ratio between a color and its background ranges from 1-21 based on its luminance (the intensity of light emitted) according to the World Wide Web Consortium (W3C).

**The W3C recommends the following contrasts for body text and image text**
Text type | Color contrast ratio |
Large text (at 14 pt bold/18 pt regular and up) and graphics
 | At least 3:1 against the background |
Small text
 | At least 4.5:1 against the background |

Disabled states do not need to meet contrast requirements.

### Clustering elements

Some non-text elements, such as button containers, should meet a contrast ratio of 3:1 between their container color and the color of their background. Consider the following patterns for combining elements and tones, which are grounded in Material's research into contrast and functional changes when elements are combined.

[Learn more about color contrast for accessibility](/m3/pages/color/how-the-system-works#e1e92a3b-8702-46b6-8132-58321aa600bd)

Elements that are clustered with others, such as a group of buttons, require the user to distinguish each one from the group. 

These elements benefit from 3:1 contrast between themselves and the background.

_footer: The contrast of the button container color against the background color is less than Material's required contrast of 3:1_
_altText: Two colors applied to button container and UI surface with contrast that fails 3:1 minimum._

_footer: The container color exceeds Material's required minimum contrast of 3:1 against background color_
_altText: Two colors applied to button container and UI surface with contrast that passes 3:1 minimum._

Elements that stand on their own and apart from other elements on the screen, such as a FAB, are already distinguishable to users because of their prominence. These elements don’t benefit from 3:1 contrast between themselves and the background.

_footer: Standalone components, such as FABs, don’t need to meet Material's minimum contrast of 3:1 between the container and background colors because of their prominence_
_altText: Two colors applied to the FAB container and UI surface that fail the minimum contrast of 3:1._

When placing components together in a cluster, use components or types of components that each achieve at least 3:1 contrast between themselves and the background.

_footer: Each button's container color has less than Material's required minimum contrast of 3:1 against the UI background, leading to poor contrast support for users with low vision_
_altText: A cluster of three buttons with the same container color that fails the minimum contrast of 3:1 with the UI surface._

_footer: Each button's container color has contrast of at least 3:1 against the UI background, leading to better contrast support for users with low vision_
_altText: A cluster of three buttons with the same container color that passes the minimum contrast of 3:1 with the UI surface._

<!-- section: Structure -->

## Hierarchy

When navigation is easy, users understand where they are in your app and what’s important. To emphasize which information is important, multiple visual and textual cues like color, shape, text, and motion add clarity.

### Types of feedback

Visual feedback (such as labels, colors, and icons) and touch feedback show users what is available in the UI.

### Navigation

Navigation can have clear task flows with minimal steps, easy-to-locate controls and clear labeling. Focus control, or the ability to control keyboard and reading focus, can be implemented for frequently used tasks.

Every added button, image, and line of text increases the complexity of a UI. **Y****ou can simplify how your UI is understood by using:**

- Clearly visible elements
- Sufficient contrast and size
- A clear hierarchy of importance
- Key information that is discernable at a glance

### Levels of importance

**To convey an item’s relative level of importance:**

- Place important actions at the top or bottom of the screen (reachable with shortcuts)
- Place related items of a similar hierarchy next to each other

### Visual hierarchy

To enable the screen reader to read out content in the intended order, it’s important for designers to collaborate with developers – both for writing out the HTML in the correct order, and understanding how screen readers will interpret designs.

While CSS determines the layout and appearance of a page, screen readers rely on the top-down structure of HTML on any platform (mobile or web). This structure creates a map for the screen reader to follow when reading the content.

_footer: An example of how content hierarchy in a screen can be identified in a logical reading order to optimize for the ways assistive tech, such as screen readers, may interpret information_
_altText: Example of a mobile app using 4 content cards in a 2 by 2 grid. They reading order is top left, to top right, then bottom left, then bottom right._

## Web landmarks and headings

**Define content and UI layout to improve navigation and comprehension.**

Assistive technologies (AT) rely on clear, delineated structures to process page information, navigating primarily through the use of headings and landmarks. Many assistive technologies, such as screen readers, translate a design into a linear experience, which means that many users interact with content in hierarchical, predetermined order. Therefore, thinking through structural decisions in advance can improve the accessibility of a product.

**For web only**: Landmarks and headings help assistive-technology users orient themselves to a web page and allow for easy navigation and traversal across large sections of a document or page. 

By **classifying and labeling sections of a page**, structural information that is conveyed visually through layout design can also be represented in code.

_footer: Example of a page diagram mapping the areas for a UI in order to consider the relative landmarks and headings_
_altText: Diagram of a website, showing different regions and their associated landmarks and headings._

### Identifying landmarks and headings

#### **1. Define landmarks**

Landmarks are large blocks of content that establish the high-level structure of your layout. They're a set of Accessible Rich Internet Applications (ARIA) roles that provide easy access to, and important meaning for, common content areas of a web page. 

There are eight landmark roles: **navigation, search, main, banner, complementary, contentinfo, region, and form**. 

The eight landmark roles in the W3C ARIA guidelines include:

- **Navigation**: Contains lists of navigation links (there can be multiple, in which case you should differentiate in label)
- **Search**: A search field
- **Main**: The main content area as defined by UX. There should be only one.
- **Banner**: Typically the header; content repeated from page to page, often contains navigation and toolbars. There should be only one.
- **Complementary**: A sidebar or aside to main content that can stand alone without the main content
- **Contentinfo**: Typically the footer; contains information describing the site and its content (for example,  copyright). There should be only one.
- **Region**: Content regions are important content blocks. They can be nested inside the “main” landmark. Regions should be labeled with names that make the purpose of that region clear.
- **Form**: Takes and stores user info.

#### **Add accessibility labels**

Add **clear and specific labels** to any landmark roles that appear multiple times (regions or navigation typically). This will help users differentiate information. 

Labels should be added to **all regions**, as well as any landmark where a label will enhance meaning. For example, explaining the contents or purpose of a sidebar. 

**Don't repeat the landmark role within a label**.

_footer: This layout has two areas assigned the navigation role. Each landmark should get a unique label to help users tell the difference between elements._
_altText: Diagram labeling two regions with a navigation role with the labels primary and pagination_

#### **2. Define headings**

Assistive technology users often navigate web pages with the help of headings. They create a clear hierarchy to help users navigate and take action.

- Identify headings based on content hierarchy, rather than visual styling
- Headings should not skip a level, for example, don't go from H2 to H4 without using an H3
- Map content on your pages to headings (H1–H6) in sequential order based on the hierarchy of your content
- A single H1 for the page title is recommended

_footer: Example of headings marked up in code_
_altText: Diagram labeling different headings_

#### **Consider hierarchy in addition to style**

**Ensure that headings correspond with meaningful titles**. If they don't, consider changing the titles in the UI to benefit the experience of all users or adding a label for assistive tech.

Heading levels are informed by the layout's information architecture—the structural hierarchy that’s applied to a set of items. The page’s visual styling does not need to match the heading levels in terms of prominence and visual hierarchy.

## Target sizes

Material Design’s target guidelines can help users who aren’t able to see the screen, or who have difficulty with small touch targets, to tap elements in your app.

_altText: Target guidelines on buttons for easy accessibility._

### Touch and pointer target sizes

Touch targets are the parts of the screen that respond to user input, extending beyond the visual bounds of an element. For example, an icon may appear to be 24 x 24dp, but the padding surrounding it comprises the full 48 x 48dp touch target.

For most platforms, consider making touch targets at least 48 x 48dp. A touch target this size results in a physical size of about 9mm, regardless of screen size. The recommended target size for touchscreen elements is 7-10mm. It may be appropriate to use larger touch targets to accommodate a larger spectrum of users.

Note: iOS recommends 44 x 44dp targets.

_footer: Icons: 24dp  Star icon: 40dp  Touch target on both: 48dp_
_altText: A row of four 24dp icons and one 40dp icon_

### Pointer targets

Pointer targets are similar to touch targets, but are implemented by motion-tracking pointer devices such as a mouse or a stylus. 

Consider making pointer targets minimums 44 x 44dp.

_footer: Recommended target size for pointers: 44dp_
_altText: A row of four icon buttons in the bottom app bar._

### Target spacing

In most cases, targets separated by 8dp of space or more promote balanced information density and usability.

_footer: Two groups of icons showing their overall spacing and the spacing between each other  Touch target size: 48dp  Padding: 8dp_
_altText: Three icons in a row with 48dp touch target size and three icons in a row with 8dp padding between icons._

<!-- section: Flow -->

## Focus order & key traversal

People should be able to navigate and interact with your app without the use of a traditional mouse or touch screen. To support navigation by keyboard, screen reader, or other assistive technology, goals should be achievable by using **tab**, **arrow**, **and other common navigation keys**. 

Simplify your flows by: 

- strategically ordering tab stops
- reducing overall page complexity

### Use defaults

Avoid adding more work for yourself by using predefined tab ordering, unless a user journey needs special tailoring. The **default order follows the DOM** (the order of content as it's written in the source code) and **generally flows from left to right**; **top to bottom**. Keyboard navigation (key traversal) may be pre-defined within common components. Use the defaults unless you have a UX pattern or custom component that breaks from the default pattern.

### Determining user flows

#### **1. Group product use cases**

Group product use cases into primary and secondary user journeys. The priority of your use cases should influence the decisions you make about the priority of user flows.

#### **2. Define initial focus and component-level focus**

Focus refers to which control is currently the active target of user interactions, such as mouse clicks or keyboard taps. Generally, the **tab** key moves focus between interactive elements. 

Define the **initial focus** when a user loads a screen, as well as initial focus for components with multiple interactive elements, like a complex card or a dialog.

_footer: In the case of the Google homepage, even though there are links and buttons above and surrounding the search field on the page, it makes sense to put the user's initial focus on the element that supports the most common user goal_
_altText: A Google home screen showing the initial focus on the search bar._

Focus is particularly important when an element is activated by the user or the user changes context. 

For example, when a dialog is triggered, check for the following:

- Focus is set to the dialog component, likely to a specific interactive element within the dialog such as a text input field or edit button
- When the user closes or cancels the dialog, focus returns to the interactive element that initiated the action

_footer: - Define initial focus and component-level focus_
_altText: Diagram showing changing points of focus as a user opens and closes a calendar card._

#### **3. Define any atypical key traversal through the page and components**

Users should be able to complete the primary and secondary user journeys using tab, arrow keys, and other keyboard shortcuts.

_footer: Navigating the interactive elements on a card via tab_
_altText: Card with three interactive elements in the top right corner._

**Tab** typically moves focus between interactive elements and is often used as primary navigation. **Tab +** **Shift** reverses direction.

**Arrow keys** are typically used to navigate within components (for example, moving between cells in a form or traversing items in a menu.)

**Enter** activates a link or button, or sends a form when a form item has focus.

_footer: In the case of unique layouts and use cases, it can help to group a collection of interactive elements as one tab stop, and use arrow keys to traverse sub-elements  - Using Tab navigation to focus group - Using arrrow key to traverse sub-elements_
_altText: Diagram showing a group of three sub-elements, with navigation within the group assigned to arrow keys._

## Keyboard shortcuts

Keyboard shortcuts help users access menus and app functions without using a mouse on desktop apps and websites.

### Requirements

These requirements are important for helping speech users avoid activating multiple shortcuts at once and for keyboard-only users to minimize unwanted actions.

- Keyboard shortcuts should use a combination of two or more keys by default.
- Include a tutorial, list, or help center page of all custom keyboard shortcuts in your product. For example, Cmd+Z (Ctrl+Z) to undo deleting an event in Google Calendar.
- If a keyboard shortcut is activated with a single key, provide users with a way to take at least one of these actions:
**(Most preferred)**Remap the shortcut to include one or more non-printable keyboard keys.
- **(Preferred)** Activate the shortcut only when a relevant component is focused.
- **(Not preferred, only use as a temporary solution)** Turn off the keyboard shortcut.

<!-- section: Elements -->

## Labeling elements

Elements can be defined and labeled to enhance understanding of their function and reduce confusion for those navigating with assistive technology. Add accessibility labels to define roles and indicate decorative elements.

### Visual elements that need labels

- Interactive icons or buttons with no visible text or not enough context in the text (for example, an edit button with a pencil icon)
- Interactive images
- Visual cues (including progress bars and error handling)
- Meaningful icons (such as status icons)
- Meaningful images (for example, diagrams, substantive photos, and illustrations)

### Text elements need labels to add additional context

- Generic links (for example, "Learn more")
- Buttons with generic text (for example, "Save" when there are multiple such buttons on a page)

### Elements that do not need labels

- Non-interactive UI text, as this will be automatically read by the screen reader
- Buttons with sufficient text (for example, "Download image")

### Do not include the element name in labels

Do not use an element role (for example, button or menu) in your label. This identifier is automatically added when the element is assigned its proper role, typically by a developer.

### Label language style

This article uses the general term accessibility label to refer to several different types, including ARIA labels and alt tags. When accessibility labels are implemented in code, they'll be translated to the appropriate type for the intended platform. Additionally, the term **role** is used to cover both general component control types and ARIA roles for web apps. [Learn more about writing alt text](/m3/pages/alt-text)

### How to add labels

#### **1. Label elements**

[Accessibility labels](/m3/pages/alt-text) assist users who cannot rely on a product's visual interface. Thoughtful labels help make the text-based experience as usable as the visual experience. Labels should concisely describe an element's content, purpose and behavior.

_footer: Example: The accessibility labels for these icons describe their purpose—NOT what the icon looks like (for example, "magnifying glass")_
_altText: Diagram showing the labels and roles assigned to on-screen icon buttons._

#### **2. Add labels for meaningful images and interactive elements**

Add labels to visuals that convey meaning or enhance content. 

**Labels should be concise, descriptive, and convey the content and context of the image.**

This applies to infographics and other instructive images found in support docs.

_footer: The label “voice search” describes the user task (search) paired with the input method (voice)_
_altText: A microphone icon with the accessibility label "Voice Search."_

_footer: Don't include the element type (button, menu, etc.) in your label. This will automatically be added by assigning the element the proper role._
_altText: A microphone icon with the accessibility label "Microphone."_

#### **Hiding images**

Decorative icons and images that don't enhance the experience for a visually-impaired user should be annotated as decorative in order to hide them in code.

_footer: Mark decorative visual elements to "hide"_
_altText: Group of icons in a menu collectively described by the accessibility label N/A Hide Images._

#### **3. Assign a role to interactive elements**

ARIA roles apply to web apps and specify how to increase the accessibility of web pages on top of HTML. 

- For web, assign ARIA roles for all interactive elements
- For non-web, assign roles based on your design system components (button, slider, menu, etc.)

Assign ARIA roles (web) or component type (mobile) to communicate desired interaction patterns into engineering action. Note that some visual elements may look the same, but are intended to behave differently. 

Defining an interactive element's category by assigning it a role helps users of assistive technology establish expectations for how to interact with that element and anticipate what is likely to happen upon interaction.

_footer: Don't include the control type in the label. Screen readers automatically add the control, so you’d be having it repeat (for example, “Got it button button”)._
_altText: Element with the label "Got it button" and the role "Button."_

---

<!-- Source: m3.material.io · foundations_design-tokens · updated 2026-07-17T05:01:46.434Z · CC-BY 4.0 (Google) -->

## Design tokens

> Design tokens are the building blocks of all UI elements. The same tokens are used in designs, tools, and code.



<!-- section: Overview -->

-
Tokens point to style values like colors, fonts, and measurements

-
Use design tokens instead of hardcoded values

-
Each token is named for how or where it’s used (for example, **md.comp.fab.primary.container.color** sets the container color for a FAB)

-
Even if a token’s end value is changed, its name and use remain the same

-
Material Design has three classes of tokens: [reference](/m3/pages/design-tokens/overview#6a0933c0-50f5-4dd6-b055-b7c4ff2c1535), [system](/m3/pages/design-tokens/overview#7f084930-cf5f-4b7e-b83c-614888f18a77), and [component](/m3/pages/design-tokens/overview#b4d6bb35-ee69-4908-bcb4-b33b0a1997e2)

_footer: Using design tokens instead of hardcoded values can streamline the work of building, maintaining, and scaling products with a design system_
_altText: FAB container color token in a design mock, code, and product_

## Resources

Type | Link | Status |
Design | [Design Kit](http://goo.gle/m3-design-kit) (Figma) | Available |
[Material Theme Builder Figma plugin](https://goo.gle/material-theme-builder-figma) | Available |
Implementation | [Material baseline theme and tokens](https://github.com/material-foundation/material-tokens) (DSP) | Available |

## What’s a design token?

Design tokens are small, reusable design decisions that make up a design system's visual style. Tokens replace static values with self-explanatory names.

A design token consists of 2 things:

-
A code-like name, such as **md.ref.palette.secondary90**

-
An associated value, such as **#E8DEF8**

The token's value can be one of several things: A color, typeface, measurement, or even another token.

_footer: Example of a reference token and its color value_
_altText: Token md.ref.palette.secondary90 with arrow pointing to lilac color swatch #E8DEF8._

Design tokens meaningfully connect style choices that would otherwise lack a clear relationship.

For example, if a designer's mock-ups and an engineer's implementation both reference the same token for the “secondary container color,” then they can be confident that the same color is being used in both places. This applies even if the hex value assigned to that token gets updated.

_footer: Example of tokens assigned to the secondary and on secondary color roles of a FAB’s container and icon, respectively_
_altText: Diagram of FAB indicating system tokens: Secondary for surface color and on secondary for icon color_

## Why are tokens important?

Tokens make it possible for a design system to have a single source of truth – a repository where style choices are recorded and changes can be tracked.

Because tokens are reusable and purpose-driven, they can define system-wide updates to themes and contexts. For example, you can use tokens to systematically apply a high-contrast color palette for improved visibility, or change the typographic scale to ensure that text is legible on a TV screen.

By using tokens for design and implementation, style updates propagate consistently through an entire product or suite of products. They also help designers and engineers "speak the same language,” reducing confusion during handoff from design to implementation.

_footer: As design systems evolve, certain values will change. With design tokens, we can track changes and ensure consistency across our products._
_altText: Diagram of how changing the value of a token cascades from design system into a product area and 3 products_

## Deciding if tokens are right for you

#### **Tokens will be most helpful if:**

- You plan to update the design of your product or are building a product from scratch
- Your design system is applied across a suite of products or platforms
- You want to make it easy to maintain or update styles in the future
- You want to get the most out of the Material Design system, including features like dynamic color

#### **Tokens will be less helpful if:**

- You have an existing app using hard-coded values that is unlikely to change in the next year or two
- Your product does not have a design system

## Tokens & Material Design

In the past, Material styles were communicated through guidelines, design files, tools, and platform-specific component libraries.

With design tokens, you can now download, customize, and apply Material styles and integrate them across your design and development process.

Tokens allow decisions to be documented in a platform-agnostic and shareable format.

_footer: Design tokens provide a central repository for design choices, with a variety of integration points for engineers and designers_
_altText: Diagram of design token connected to design tool and platform code_

On this site, you’ll see tokens listed in interactive modules.

These modules let you quickly look up the default baseline value stored by tokens for color, font, font size, font weight, etc. They also show the relationship between a role, its system token, reference token, and stored pre-set value.

_footer: Example of a token module_
_altText: A token module for the color system with 4 color swatches for the primary color set._

You’ll also see tokens in the specs tabs of component articles.

Tokens are first grouped by **state** (enabled, disabled, hover, etc) and then by **element**, which is the part of the component that a token or value applies to, such as the container or label text.

Columns include:

- **Name**– The component style aspect that the token applies to, such as color or font
- **Token ID** – The token defining the component style aspect
- **Description** – Optional descriptive info
- **Context/value** – The value stored in the token for a given context

_footer: The diagram and token module for elevated button_
_altText: A token module for an elevated button organized by state (enabled, disabled, etc), then element (container, label text)._

### How to use token modules

Let's say you need to verify the color role for a filled button's label text.

Navigate to Common buttons > Specs, find the token module for filled buttons, and search for the "label text" tokens under elements.

Copy the color token and paste it in code, or compare it to the color role in Figma.

_footer: Diagram and token table for filled button label color_
_altText: How to find the label text color token._

## Parts of a token name

The parts of a token name are separated by periods and proceed from the most general information ("md") to the most specific ("on-secondary").

- All token names in a design system start with the system name (such as “md” for Material Design)
- An abbreviation for the token class: “ref” for reference tokens, “sys” for system tokens, and “comp” for component tokens
- The token ends with descriptive words communicating the token’s role

_footer: - Communicates design system - Communicates token class - Communicates token’s purpose_
_altText: Diagram of the 3 parts of a design token name: system prefix, token type, and role description_

## Classes of tokens

There are three classes of tokens in Material:

- Reference tokens All available tokens with associated values.
- System tokens Decisions and roles that give the design system its character, from color and typography, to elevation and shape.
- Component tokens The design properties assigned to elements in a component, such as the color of a button icon.

With three classes of tokens, teams can update design decisions globally or apply a change to a single component.

_footer: A button that receives its container color through a system of three tokens that define scalable color values. The color tokens point to a specific hex value that can easily change without impacting the token syntax._
_altText: Color value stored in reference token stored in system token, stored in component token, appearing as the container color of a FAB_

### Reference tokens

These tokens make up all of the style options available in a design system.

They usually point to a static value – such as a color hex code or font size – but can also point to other reference tokens. Reference tokens don't change based on context.

By providing a list of options, reference tokens give your team a starting point of approved colors, typography, measurements, etc.

All reference tokens start with the prefix **ref**.

_footer: Color and typography reference tokens and their values_
_altText: Token md.ref.palette.secondary90 pointing to #E8DEF8. Toke md.ref.typeface.plain-medium pointing to Roboto Medium_

### System tokens

These are the decisions that systematize the design language for a specific theme or context.

System tokens define the purpose a reference token serves in the UI.

This is where theming occurs. The system token can point to different reference tokens depending on the context, such as a light or dark theme.

Whenever possible, system tokens should point to reference tokens rather than static values. 

All system tokens start with the prefix **sys**.

_footer: System tokens, reference tokens, and their values_
_altText: System token md.sys.color.secondary-container pointing to token md.ref.palette.secondary90 pointing to #E8DEF8. System token md.sys.typescale.label-medium.font pointing to token md.ref.typeface.plain-medium pointing to Roboto Medium_

### Component tokens (in development)

These represent the elements required to compose a component, such as containers, label text, icons, states, and their values such as size, shape, color, or elevation.

Whenever possible, component tokens should point to a system or reference token, and not contain hardcoded values such as hex codes.

Not every stylistic choice of a component will be able to be expressed as a token, but whenever a design choice applies to multiple components of similar intent, a token should be used.

All component tokens start with the prefix **comp**.

_footer: Component tokens, system tokens, reference tokens, and their values_
_altText: Extended FAB component tokens for container color and label text pointing to system tokens, pointing to reference tokens, pointing to resolved values_

## Contexts

Tokens can point to different values depending on a set of conditions. These conditions are called contexts and their resulting values are called contextual values.

Examples of different contexts include: device form factors, dark theme, dense layouts, and right-to-left writing systems.

You can think of a context as a kind of tag. If a token value is tagged with dark theme then it will override the default token value in a dark theme context.

_footer: The same system token for background color can point to different reference tokens depending on the context: Light theme or dark theme_
_altText: Diagram of system token for background color pointing to different values depending on the theme context_

<!-- section: How to use tokens -->

## Download Material baseline tokens

Material Design’s baseline theme includes design tokens and default values. [Download the theme](http://github.com/material-foundation/material-tokens) as a Design System Package (DSP) to customize, collaborate on, and use in your own designs and product code.  [Learn about the DSP JSON format](https://github.com/AdobeXD/design-system-package-dsp)

## Use tokens in Figma

To begin, install the [Material Theme Builder](https://goo.gle/material-theme-builder-figma) Figma plugin from the community page.

### Generate tokens

- Open Figma and navigate to: **Plugins** > **Material Theme Builder** > **Open Plugin**
- Select **Get started**, this will create **material-theme** with baseline values by default. Color and text styles will begin populating the right hand design panel. When your tokens are fully generated, your artboard will contain tonal palettes for light and dark color schemes, as well as a default type scale.
- Your tokens are now represented as [Figma styles](https://help.figma.com/hc/en-us/articles/360039238753-Styles-in-Figma) that can be used throughout your designs

### Update token values

#### Using the Material Theme Builder Figma plugin (updates colors only)

- Open Figma and navigate to: **Plugins** > **Material Theme Builder** > **Open Plugin**
- Choose the colors. Updated color and text styles will begin populating the right hand design panel.
- Your updated tokens are now represented as [Figma styles](https://help.figma.com/hc/en-us/articles/360039238753-Styles-in-Figma) that can be used throughout your designs

#### Using Figma styles

- In Figma, navigate to the file in which the tokenized style is defined. Shortcut: right click the style in the right hand sidebar and select **Go to style definition.**
- In the right hand sidebar, hover over the style you want to update and **select the adjust icon when it appears**. Or, right click the style in the style picker and select **Edit style**.
- Make your changes to the token name, description, properties, etc. using the **Edit style panel**. Close the panel when finished.

### Use tokens in product mock-ups

- Instead of manually setting the color or typography for elements in a layout, apply the [Figma styles](https://help.figma.com/hc/en-us/articles/360039238753-Styles-in-Figma) representing your design tokens. This helps ensure that developers will correctly understand and apply your design choices.

### Use tokens with the Material Design Kit

- Duplicate the Material Design Kit in Figma
- Navigate to **Plugins** > **Material Theme Builder** > **Open plugin**
- With components selected, **select swap**. This will swap the baseline Material token style values with your own generated token style values.

### Export tokens

- Open Figma and navigate to: **Plugins** > **Material Theme Builder** > **Open Plugin**
- Navigate to the **Export tab**. Select the format you want to export for (Android, Jetpack Compose)
- Name your .zip file and select **Save**

Your tokens are ready to share!

---

<!-- Source: m3.material.io · foundations_glossary · updated 2026-08-18T13:31:11.452Z · CC-BY 4.0 (Google) -->

## Material A-Z

> Get to know the key terms and concepts behind Material, from A to Z



<!-- section: Tab 1 -->

### Adaptive design

A design approach in which the interface changes based on known user, device, or environmental conditions. Adaptive design in Material includes layout and component adaptations.

### App bar

A component that displays information and actions at the top of a screen. [Learn more about app bars](/m3/pages/app-bars/overview)

### Banner

A component displaying a prominent message and related optional actions.

### Button

A component helping people initiate actions such as sending an email, sharing a document, or liking a post. [Learn more about buttons](https://m3.material.io/components/all-buttons)

### Bottom sheet

A component containing supplementary content that’s anchored to the bottom of the screen. [Learn more about bottom sheets](/m3/pages/bottom-sheets/overview)

### Card

A component containing content and actions that relate information about a subject. [Learn more about cards](/m3/pages/cards/overview/)

### Checkbox

A component allowing users to select one or more items from a set. Checkboxes can turn an option on or off. [Learn more about checkboxes](/m3/pages/checkbox/overview)

### Chip

A component for helping people enter information, make selections, filter content, or trigger actions. Chips can show multiple interactive elements together in the same area, such as a list of selectable movie times, or a series of email contacts. [Learn more about chips](/m3/pages/chips/overview/)

### Color: Baseline scheme

The **baseline scheme** refers to the group of selected tones that make up the default colors values used for light and dark themes.

### Color: Dynamic color

A customization feature in which a user-generated color scheme is mapped to an app’s color scheme.

Dynamic color is reflected in apps that accept user-generated schemes as inputs for color roles in an app. Dynamic color isn’t simply the output of the Material Theme Builder, or an algorithmic color scheme, but is the presence of a changeable color role that renders an app’s appearance dynamic in response to user input.

### Color: Extended color

A color specified (in addition to key colors) in order to fill color roles for custom schemes. Extended color is a category for idiosyncratic color roles and applications, such as brand expression or conventional (semantic) meanings.

### Color: Key color

A key color is not an extracted color–it’s a derivation of the source color. Key colors are a concept useful to understanding dynamic color, but are not used in code. The term describes any color that undergoes hue and chroma transformation of a source color. A key color is the basis for a tonal palette.

### Color: Scheme

Any mapping of color roles to specific tones from a tonal palette. Schemes consist of multiple color roles. A **dark scheme** informally describes a group of colors using the tones from a group of palettes that are mapped for a dark theme.

Note: A **light scheme** is not the same as a **light theme.***See theme.*

### Color: Source color

The single color that’s extracted to define all five key colors is called a source color. While it may not be needed in code, it’s a useful distinction for understanding that a dynamic color scheme has its root in one initiating color, AKA hue, chroma, and tone. **Key colors** are defined in relationship to the **source color’s** *hue*.

### Color: Tonal palette

A tonal palette comprises a 13-tone range that serves as the basis for mapping tones to specific roles. A tonal palette offers variations in tonality so that a color scheme automatically provides contrast and visual differentiation within any color group, such as primary.

### Color: Tone

A grouping of tones are colors with the same hue and chroma. Informally, tone means degrees of lightness. 

**In code**: Tone.of(hex code).get(tone) or Tone.of(hue, chroma).get(tone) 

**In design guidance**: “A change in a color’s tone can be used to distinguish interaction states or visual interest to component elements.”

### Color: User-generated schemes

An aspect of dynamic color that describes the colors derived and applied from an individual user’s wallpaper selection or Android preset colors.

### Condition

A signal that determines when and how an adaptive layout or component should adapt.

### Contrast

Difference between colors. For accessibility, contrast refers strictly to the difference in tone. A difference of 40 in tone guarantees a [WCAG](https://www.w3.org/WAI/standards-guidelines/wcag/) contrast ratio ≥ 3.0; a difference of 50 in tone guarantees a contrast ratio ≥ 4.5.

### Customization

A modification made to a UI reflecting an app, OEM, or individual user's visual preferences and brand. Customization can focus on individual UI elements (for example, styling the color of a component or adding optional actions to a template), or it can be implemented globally (for example, applying a set of styles as a theme across the UI).

### Dark theme

A dark theme is a low-light UI that displays mostly dark surfaces.

### Data table

A component displaying sets of data across rows and columns.

### Date picker

A component that lets users select a date, or a range of dates. [Learn more about date pickers](/m3/pages/date-pickers/overview)

### Design attribute

The style aspect that a design token or hard-coded value applies to, such as color or font.

### Design guidelines

Guidelines are descriptive written and illustrated docs that demonstrate usage and behavior mainly through examples. They're the long-form discussion of specs that help designers and developers with problem-solving and decision-making.

### Design specs

Specs are annotated designs and docs that specify the values and parameters that define a component or a feature’s coded capabilities.

### Design System Package (DSP)

An open-format folder structure created by Adobe to help teams share design system information across tools. [Learn more about the DSP format](https://github.com/AdobeXD/design-system-package-dsp)

### Design tokens

A design token represents a small, reusable design decision that’s part of a design system's visual style. Tokens replace static values with self-explanatory names. [Learn more on the design tokens page](/m3/pages/design-tokens/overview)

### Design tokens: Context

The set of conditions in which tokens can point to non-default values (for example, **dark theme, dense layout**).

### Design tokens: Role

A shortened version of the system token name (for example, **Secondary container color**; **Headline 1**).

### Design tokens: Types

- **Reference tokens**: All available tokenized values. (for example, **md.ref.palette.secondary200**)
- **Component tokens**: Component tokens define the design attributes of elements in a component, such as the color of a button container
- **System tokens**: The choices or roles that make the system, from color to typography, elevation, and shape. (for example, **md.sys.color.secondary-container**)

### Design tokens: Value

The information defining a design attribute, either stored in a token or hard-coded.

### Dialog

A component providing important prompts in a user flow. They can require an action, communicate information, or help users accomplish a task. [Learn more about dialogs](/m3/pages/dialogs/overview/)

### Divider

A thin line that groups content in lists and layouts. [Learn more about dividers](/m3/pages/divider/overview)

### Element

The part of the component that a token or value applies to, such as the container or label text.

### Extended FAB

A component for helping people take primary actions. They're wider than FABs to accommodate a text label and larger target area. [Learn more about extended FABs](/m3/pages/extended-fab/overview/)

### Floating action button (FAB)

A component representing the most important action on a screen. They put key actions within reach. [Learn more about FABs](/m3/pages/fab/overview/)

### HCT

HCT is an abbreviation of hue, chroma, tone. It’s the name of the color space that enables dynamic color. HCT is based on CAM16 **hue** and **chroma**; the L* construct for luminance from L*a*b* (CIELAB, 1976) is denoted as T for **tone**.

### Image list

A component displaying a collection of images in an organized grid.

### Libraries

Developer libraries supported by Material 3 include Android and Jetpack Compose, with in-progress support being developed for Flutter and Web.

### List

A component comprised of continuous, vertical indexes of text or images. [Learn more about lists](/m3/pages/lists/overview)

### Material Components

Open-source UI elements created to help developers implement Material Design across Android, Flutter, and the web.

### Material Design

Material is an adaptable system of guidelines, components, and tools that support the best practices of user interface design. Backed by open-source code, Material streamlines collaboration between designers and developers, and helps teams quickly build beautiful products. 

Material was launched in 2014 and has evolved over the years.

**Material Design 1** (M1): The first generation of Material Design, launched in 2014, is archived and accessible at: material.io/archive/guidelines.

**Material Design 2** (M2): The second generation of Material Design, launched in 2018, introduced Material Theming and code for Material Components.

**Material Design 3** (M3): The third generation of Material, launched in 2021, includes the Material You features like dynamic color. 

-
**Material You**: The new Material visual style and set of features embracing the personal and expressive needs of individual users, part of Material Design 3

### Material Theming

The ability to systematically customize Material Design to better reflect your product’s brand.

While a scheme represents selections or a subset of a single style group, **theme** describes a set of multiple styles and attributes in combination. Themes adjust global styles to adjust for a given user context or preference, such as low light or high contrast. For example, **dark theme** describes design decisions beyond color since adjustments to elevation and state are also integral to expressing a dark UI effectively.

### Menu

A component that displays a list of choices on a temporary surface. [Learn more about menus](/m3/pages/menus/overview)

### Mode

Binary setting provided by a system to help people use the device better. Examples: **Focus mode**, **airplane mode**, and **battery saver mode**.

### Navigation bar

A component offering a persistent and convenient way to switch between primary destinations in an app. [Learn more about navigation bars](/m3/pages/navigation-bar/overview/)

### Navigation drawer

A component providing ergonomic access to destinations in an app. [Learn more about navigation drawers](/m3/pages/navigation-drawer/)

### Navigation rail

A component providing access to primary destinations in apps when using tablet and desktop screens. [Learn more about navigation rails](/m3/pages/navigation-rail/overview/)

### Progress indicator

A component displaying an unspecified wait time or the length of a process. [Learn more about progress indicators](/m3/pages/progress-indicators/overview)

### Orbiter

Floating UI elements that control the content within spatial panels.

### Pane

The building blocks of a layout. Content and actions are grouped into panes, which adapt the content to best fit the screen.

### Radio button

A component allowing users to select one option from a set. [Learn more about radio buttons](/m3/pages/radio-button/overview)

### Role

Short nickname describing the purpose of a design token within a design system. Also known as slots. Examples: **On surface**; **Body 1**.

### Side sheet

A component containing supplementary content that’s anchored to the left or right edge of the screen.

### Slider

A component that allows users to make selections from a range of values.

### Snackbar

A component that provides brief messages about app processes at the bottom of the screen. [Learn more about snackbars](/m3/pages/snackbar/overview/)

### Spatial

Relates to the placement of UI in space through extended reality (XR).

### Style

One or more properties, typically customizable, that define an aspect of a UI's appearance, such as [color](/m3/pages/color), [typography](/m3/pages/typography/overview), or shape.

### Switch

A component that toggles the state of a single item on or off. [Learn more about switches](/m3/pages/switch/overview)

### Tab

A component used to organize content across different screens, data sets, and other interactions. [Learn more about tabs](/m3/pages/tabs/overview)

### Text field

A component that lets users enter and edit text. [Learn more about text fields](/m3/pages/text-fields/overview)

### Theme

A set of styles, such as color, elevation, and type, that can be applied globally to an app's UI components as a way to consistently adjust aspects of appearance in an app.

### Time picker

A component that helps users select and set a specific time. [Learn more about time pickers](/m3/pages/time-pickers/overview)

### Toolbar

A component displaying navigation and key actions at the bottom of mobile screens. [Learn more about toolbar](/m3/pages/toolbars/overview)

### Tooltip

A component that displays informative text when users hover over, focus on, or tap an element.

### XR

Extended reality includes UI viewed in virtual reality or in passthrough blended with the physical environment.

---

<!-- Source: m3.material.io · foundations_customization · updated 2026-07-17T04:59:31.042Z · CC-BY 4.0 (Google) -->

## Customizing Material

> Customization creates unique branded products with familiar patterns and accessible interactions



<!-- section: Tab 1 -->

_altText: Examples of 4 identical mobile UI screens using 4 different color sets_

## Dynamic color makes personal devices feel personal

M3 opens up new possibilities for both brand colors and individual color preferences to converge in one-of-a-kind experiences. The color system embraces the need for color to reflect an app’s design sensibility, while also honoring the settings that individuals choose for themselves. 

By enabling dynamic color, an app can retain the colors that define and differentiate a product, while also giving users more control over the styles that matter most to them.

#### Applying a brand color system

With dynamic color and M3 color schemes, your app’s colors automatically adapt and integrate with user settings. 

M3 supports systematic applications of custom parameters to help define and maintain the styles that convey your brand. 

The color system automatically handles critical adjustments that provide accessible color contrast, legibility, interaction states, and component structure. Dynamic color also works for custom (non-Material) components.

_footer: Apps can take on an array of colors from baseline schemes, user-generated dynamic colors, or custom colors_
_altText: Animation showing 3 different source colors cascading through a UI to recolor elements on the screen_

## Get started

To take advantage of personalization features, you’ll need to **build a custom color scheme with the M3 color system**. 

In order for your app to respect a user's device and app-level settings, **you'll implement a custom theme that user-generated color schemes can map to**. 

Additionally, using a custom theme ensures that your app has a fallback color scheme available for users who don't enable dynamic color.

_footer: A user-generated color scheme can flow through apps that use a custom theme_
_altText: collage of views of a mobile UI that show a user's setting and preference for a green primary color flows through system UI harmoniously_

### Set-up and tutorials

Dynamic color is both a user setting and a developer choice. You can apply dynamic color selectively to work alongside your brand color scheme. For example, a profile or account screen in your app can reflect a user’s color scheme settings, adding individuality to a personal space in an app.

#### Set-up

- Your existing brand parameters can be integrated with Material Design for consistent application across your product
- You can also start from scratch with Material Design and create a new, complete color system for a project

#### Dynamic color tutorial

The [dynamic color codelab](https://goo.gle/visualize-dynamic-color) is a hands-on walkthrough that helps visualize how designs and brand colors interact with dynamic color. It helps take you to the next steps in applying color to your designs using the [Material Theme Builder](https://goo.gle/material-theme-builder-figma) plugin for Figma.

#### Material Theme Builder

With built-in code export, the [Material Theme Builder](https://goo.gle/material-theme-builder-figma) Figma plugin makes it easy to visualize your designs, migrate to the M3 color system, and take advantage of dynamic color. 

The Material Theme Builder creates **color and type tokens** that can be exported into multiple code formats. Tokens are an important tool for creating and maintaining a source of truth for style values. The Figma plugin creates tokens in the form of Figma styles to connect with existing mock-ups, brand style guides, and even design systems.

[Material tokens](https://github.com/material-foundation/material-tokens) are ready to use in formatted theme files, including [Design System Package (DSP)](https://github.com/AdobeXD/design-system-package-dsp). A DSP is a cross-platform file format that represents design system information. [Learn more about design tokens](/m3/pages/design-tokens/overview).

_footer: The Material Theme Builder Figma plugin helps you create custom color schemes and export to multiple code formats_
_altText: Example of the start screen for the Material Theme Builder Figma plugin. The plugin UI is shown alongside a range of purple tones as an example of a color palette that can be generated._

## Custom color schemes

The Material Theme Builder helps create custom color experiences, whether you're working with established brand parameters or have yet to define your app's colors.

In the Material Theme Builder you can identify and input one or more color to define your color scheme. Adding a second or third color is optional and will influence the resulting color scheme.

Mapping your app colors to the custom scheme's source colors aligns the roles and logic of [dynamic color in M3](/m3/pages/dynamic-color/overview). 

**Brand colors** can be added to the tool as a single-use color or as a complete brand palette with a range of tones that lend consistent, comprehensive color expression across your app. 

If your app uses a single brand color or a limited brand palette, you can input your primary brand color as your custom color scheme's source color. The input color will be used to generate a scheme that provides you with complementary tones to round out a scheme.

_footer: Examples of brand attributes (left) that can be used to generate and apply a dynamic color scheme (right)_
_altText: Four color swatches are seen first in isolation and then as inputs to the material theme builder UI. Then, the color inspiration and typeface combine in a final UI for a plant brand app._

### Color roles

Depending on the purpose in a UI, key colors are assigned roles that map to elements in components. The five essential color groups with role assignments are:

- Primary
- Secondary
- Tertiary
- Neutral
- Neutral Variant

An input color generates a tonal palette that's used to fill the range of color roles needed, such as primary, on-primary, and primary container. [Learn more about using color roles](/m3/pages/color-roles/)

_footer: Examples of color roles in the Plant Care UI mapped to design tokens_
_altText: A mobile UI is seen with diagram labels showing where specifc elements have been mapped to specific colors, such as on-surface, or primary._

---

<!-- Source: m3.material.io · foundations_writing · updated 2026-07-17T05:36:35.129Z · CC-BY 4.0 (Google) -->

## Writing and text

> Ensure text is helpful, clear, and resilient to change



<!-- section: Best practices -->

## Accessibility text

Accessibility text refers to text that is used by screen reader accessibility software, such as Google’s TalkBack on Android, Apple’s VoiceOver on iOS, and Freedom Scientific’s JAWS on desktop. Screen readers read aloud the on-screen text and elements (such as buttons), including both visible and nonvisible alternative text.

### Adjacent text

To make an image more accessible, the text in and around images should consider presenting key information about the image.

_footer: - Image - Caption - Adjacent text_
_altText: Stacked card with image, caption, and adjacent text identified._

### Captions

Captions are the text that appear below an image. They explain contextual information about the image to help the reader understand how it relates to the content. Both sighted and screen reader users rely on captions for descriptions of images.

_footer: Use captions to help readers understand how the image relates to the content_
_altText: Stacked card with image, alt text as caption, and adjacent text identified._

### Embedded text in images

Screen readers are unable to read text that is embedded in imagery. If there is essential information embedded as text in the image, include the essential information in the [alt text](/m3/pages/alt-text).

_footer: Take caution when embedding essential information anywhere a screenreader can't access, like text inside an image_
_altText: Stacked card with image, caption overlayed on image, and adjacent text._

### Alternative text (Alt text)

Alt text helps translate a visual UI into a text-based UI. Alt text is a short label (up to 125 characters) in the code that describes an image for users who are unable to see them. Since alt text is only for images, there is no need to add “image of” or “picture of” to the alt text. A screen reader will read the alt text aloud in place of the image. 

Alt text is valuable for sighted users, as well, because alt text appears if an image fails to load. Include targeted keywords to help inform the user about the image. Keywords can also improve search engine optimization (SEO).

[Learn more about writing alt text](/m3/pages/alt-text)

_footer: Use alt text to convey what the image is showing in an informative, short phrase. Alt text example: A DJ performs a set under lights and lasers_
_altText: A DJ standing in front of music equipment with alt text underneath describing image._

## Text color

### Essential and non-essential elements

Informative images have essential and non-essential elements. Essential information should have a 3:1 minimum color contrast for large text and 4.5:1 for small text.

_footer: The illustration contains both essential and non-essential information:  - Essential: The text meets all contrast ratios and size requirements - Essential: An illustrative visual representation of the instructions that follows color contrast guidelines - Non-essential: The decorative elements create background and personality for the illustration. They do not relay information and do not have to meet Material's contrast requirements._
_altText: SIM card installation with essential and non-essential elements._

<!-- section: Text truncation -->

## Text truncation

Information should always be available to readers, even if text is truncated or wrapped.

### Background

Increased size of text, increased spacing between text, and translation into longer languages shouldn’t result in losing content. This requires designing for text truncation and creating designs flexible enough to accommodate any viewport size or increase in zoom. Some common methods of designing for larger text include text wrapping, increased height or width of components, and truncation with ellipses and hover or link.

### Requirements

Content, understandability, and functionality must not be lost when users modify their type settings. There may be exceptions to these requirements for non-Latin alphabet languages.

### Text wrapping

- “Wrapped” text extends from one line to another, increasing the height of the text container
- Text should be wrapped when it’s critical, to ensure understandability, or when there’s space in the component

_footer: Wrap text, and if it still doesn’t fit, provide a way for users to see more_
_altText: Body copy  text wrapped  inside a dialogue with an option to expand content._

_footer: Don’t cut off text without providing a way for users to view it_
_altText: Body copy  text wrapped  inside a dialogue, cut off at the bottom, without an option to expand._

### Height and width of components

- Some components can extend vertically or horizontally for more text

_footer: Use flexible component containers that change size to fit their content_
_altText: Layout of UI- cards of different sizes organized in a stacked grid._

_footer: Avoid setting text size limits that don’t fit the space in a component. Use all space available._
_altText: A stretched UI card  with a small headline and a large photograph._

### Ellipses with hover or link

- Truncated text can be replaced with an ellipsis if the text is available through a tooltip or link
- Links can be used when they’re contained in the text that’s truncated, and when the link displays what's been truncated
- If there's an ellipsis, but no way to show the truncated text, it is not accessible
- Note that this option can add difficulty for some people

_footer: Use links to reveal truncated text when space is limited, such as the ability to click a linked card to see an expanded view of its text_
_altText: A calendar with a cursor hovering  over a day of the week displays a tooltip that reads “Tuesday.”_

_footer: Don’t truncate content without providing users another way to see it_
_altText: On a multiple selection list, the marked checkbox’s label is truncated by an ellipsis._

<!-- section: Text resizing -->

## Text resizing

### Background

People with low vision or those who prefer large text must be able to scale up the size of text in a UI. This adjustment is often performed through a device OS setting or in-app option.

UIs should support a minimum text increase of 200%.

Most components behave the same when text is resized:

- Text and line height scale up proportionally, multiplied by scale value
- Padding remains constant at 1x the default size
- Spacing between elements in a component remain constant at 1x the default size

_footer: Button text displayed at 1x, 1.3x, and 2x scales. All have top and bottom padding of 8dp._
_altText: Padding is the same on the top and bottom edges of the buttons._

_footer: Left and right padding remains constant at 24dp as the text size increases._
_altText: Button text displayed at 1x, 1.3x, and 2x scales. All have left and right padding of 24dp._

When text resizing isn't controlled by the device OS, offer multipliers such as 1.5x or 2x to allow users to increase the text size. Using multipliers to scale text can result in values with decimals, but this approach is more feasible for implementation.

To calculate a font's size using multipliers, take the **default****font size** (density = 0) and **multiply it by the scale value**.

_footer: For example, if a font is 14pt at 1x scale, then the font size should be 28pt when enlarged to 2x scale: (14pt) x (scale value 2) = 28._
_altText: Button with label text at 1x and 2x scale._

Components that don't include text, like progress indicators, checkboxes, or radio buttons, aren't affected by text resizing.

_footer: When designing for text resizing, don't resize components without text_
_altText: Icon button with the icon shown at 1x scale and incorrectly at 2x scale._

_footer: UI text displayed at 1x_
_altText: Menu with labels at 1x scale._

_footer: UI text displayed at 2x in which only text and line height is enlarged; the padding between components remains the same as in the 1x UI._
_altText: Menu with labels at 2x scale._

### Designing for large type

Large type is used regularly by people with low vision and those with difficulty processing written words. They tend to increase text size:

- To make it easier to read
- To limit interruptions and focus on one task
- To avoid overwhelming their senses

Use these methods to design a product to handle large type properly.

_footer: Text that is too small and dense can appear overwhelming and difficult to read_
_altText: Menu with labels at 2x scale._

_footer: Larger text can help people focus on one decision at a time and improve understanding_
_altText: Menu with labels at 1x scale._

### Methods

Avoid common text resizing issues by increasing container size, reflowing layout, enabling scrolling, and adding tooltips.

_footer: - Unresponsive container; unintentionally clipped text - Unresponsive text - Overlapping elements - Unwanted truncation_
_altText: Side by side of 4 commonly found issues when resizing text up._

#### **Increase container size**

Resizing containers can prevent text from overlapping, clipping, or truncating.

Consider how text might reflow in a way that allows the eye to follow the end of one line to the beginning of the following line.

#### **Reflow the layout**

Consider reflowing the layout, especially when components grow very long. To accommodate larger text, components can be stacked on top of one another, rather than fixed side-by-side.

_footer: - UI displayed at 1x: buttons positioned side-by-side in a standard layout - UI displayed at 2x: buttons stacked to fit the limited horizontal width after text is resized_
_altText: left: buttons placed side-by-side. Right: buttons stacked on top of one another._

#### **Enable content to scroll**

When long strings of enlarged text don’t fit on one screen, consider adding a scrollbar to provide access to more content.

Vertical scrolling is preferable to horizontal. Users should only be asked to scroll in one direction, rather than both vertically and horizontally.

_footer: Some screens may not be able to resize and display necessary content. In this situation a scrollbar can be used to access more text._
_altText: Dialog with a lot of text at 2x size. The text is cut off but accessible when scrolling._

#### **Use touch & hold tooltips to provide enlarged labels**

Some components, such as app bars and navigation bars, position text in spaces with stricter space and character limits. In these situations, you can add a tooltip to display enlarged content in the UI.

In this case, the text size in the component remains displayed at 1x while the scaled up text is displayed in a tooltip on touch & hold.

Tooltips are the best choice for displaying enlarged text in:  

- Top app bar
- Navigation bar
- Navigation rail
- Tabs, when fixed to the top of a screen and don’t move off-screen upon scrolling

_footer: Scale up text in an adjacent tooltip to maintain space in a UI for consuming content._
_altText: Tooltip on navigation rail displays scaled up label text._

---

<!-- Source: m3.material.io · foundations_content-design_overview · updated 2026-07-17T05:27:26.453Z · CC-BY 4.0 (Google) -->

## Content design

> UX writing and information design make UIs easy to use



<!-- section: Overview -->

- UI text should be clear to anyone
- Follow [Associated Press (AP) Style](http://www.apstylebook.com) unless noted otherwise

_altText: UI content templates for various components._

## Resources

Type | Resource |
Design  | [AP Stylebook](https://www.apstylebook.com/) |

## What’s new

- Updated content and organization
- Updated guidance on first-person pronouns
- New examples and illustrations

---

<!-- Source: m3.material.io · foundations_content-design_global-writing · updated 2026-07-17T05:07:22.750Z · CC-BY 4.0 (Google) -->

## Global writing

> Global writing is easier to read, understand, and translate. This guidance is for all American English that is localized.



<!-- section: Overview -->

## Overview

### Global writing

Global writing is the practice of writing inclusively for many cultures and optimizing for localization. This makes writing easier to read, understand, and translate. Writing for localization is necessary when a product will be translated, but can also be a helpful lens when writing for anyone.

_altText: 3 apps in different languages._

<!-- section: Word choice -->

## Word choice

### Use global examples & explain local references

References to local places, holidays, and companies won’t always make sense to global audiences.

_footer: Use generalized, global examples. Most countries and cultures have holidays._
_altText: Empty wishlist screen that references the holidays_

_footer: Don’t call out a specific country or culture’s holiday_
_altText: Empty wishlist screen that references Christmas_

If it doesn’t make sense to use a global example, explain the reference in the message description so the translator can substitute a locale-specific example. Some instances where local references should be called out include:

- Locations
- Names (common first names and nicknames)
- Currencies
- Temperatures
- Date formats
- Providers (internet and cable)

_footer: Help translators understand the context by adding message descriptions_
_altText: Empty state that references New York with message description about replacing New York with a well-known city in other languages_

### Use short, simple sentences

Break text into shorter sentences. Use bullets or separate content into sections with headings. 

Other languages average at 1.5 times longer than English, so text that’s short may be long when translated.

_footer: Many languages, like German, are longer than English_
_altText: 2 screens side by side, in English and German_

### Avoid abbreviations

Abbreviations don’t translate well and can be confusing out of context. Spell things out whenever possible.

However, common abbreviations for time are acceptable.

_footer: Use clear names to refer to things_
_altText: Dialog with options that aren’t abbreviated_

_footer: Avoid abbreviations. If they're used, provide their meaning in message descriptions._
_altText: Dialog with options that are abbreviated_

### Clarify pronouns

Using pronouns, like “it,” can get tricky when translators are working with small, unconnected strings of text and when nouns have genders in many languages. Repeat the noun, or clarify the noun in a message description.

_footer: Using nouns instead of, or in addition to, pronouns can help clarify future and past user actions_
_altText: Photo app with snackbar that reads “Couldn’t move photo”_

_footer: Avoid using pronouns when it’s unclear what nouns they’re referring to, especially when explaining user actions_
_altText: Photo app with snackbar that reads “Couldn’t move it to ‘Travel’ folder because it’s unavailable”_

### Clarify “this” and “that”

Don’t start a sentence with "this" or "that" unless it's immediately followed by the noun. When the noun is unclear, the sentence is more difficult to translate.

_footer: Make sure it’s clear who text is referring to_
_altText: Form with clear writing that doesn’t use “this” or “that”_

_footer: Avoid using “this” and “that”_
_altText: Form with a subhead that reads “This can be seen by your IT administrator.” It’s not clear what “this” refers to._

### Avoid idiomatic, colloquial, and polite expressions

Idiomatic or colloquial phrases can be confusing if the meaning isn’t clear. If you use them, clarify the purpose and context of the phrase to help the translator choose an appropriate alternative.

Avoid polite expressions, such as “Please,” “Sorry,” and “Thank you,” especially in error messages. However, "please" may be used when asking the user to do something inconvenient.

_footer: Clear, everyday language can be used in an expressive and whimsical way when paired with imagery_
_altText: Empty state with illustration that reads “Let’s go”_

_footer: Idiomatic phrases can be difficult for everyone to understand and for translators to localize_
_altText: Empty state with illustration that reads “Let’s get this party started”_

### Reduce technical jargon

Technical terms don't always translate. Descriptions should be simple, and in some cases literal, to avoid confusion when translating.

_footer: Plain language is easier for everyone to understand_
_altText: Dialog that prompts people to sign up to try new products_

_footer: Confusing language makes it difficult for people to understand the actions they’re taking_
_altText: Wordy and confusing dialog that prompts people to sign up for new communication preferences_

### Clarify ambiguities

Some words have multiple meanings. For example, “traffic,” “filter,” and “change” can be used as either nouns or verbs. Avoid using both meanings of the word in the same string or body of text. If a word has the potential to be confusing, provide as much context as possible in the message description so the translation will be accurate.

_footer: Clarify words that have multiple meanings. “Home” could reference a homepage or where someone lives._
_altText: Screen displaying devices and speakers at home, next to bottom app bar with “home” button_

---

<!-- Source: m3.material.io · foundations_content-design_style-guide · updated 2026-08-04T07:53:19.197Z · CC-BY 4.0 (Google) -->

## Style guide

> UI text should be understandable by anyone, anywhere



<!-- section: UX writing best practices -->

### Explain consequences

Emphasize the results of the user’s potential action in neutral, direct language. Avoid cautions or warnings that might sound alarming, intimidating, or condescending. Focus instead on communicating the consequences of a function.

_footer: Tell users what will happen if they take an action and how they can undo it_
_altText: "Move to trash?" dialog with the message "Big birthday bash will be deleted after 30 days."_

_footer: Don’t misrepresent consequences or try to influence a user’s decision_
_altText: "Are you sure you want to move to trash?"dialog with the message "You'll be able to find "Big birthday bash" in your trash for 30 days."_

### Use scannable words and formats

People scan UI text in search of the most meaningful content to them. Help by using specific titles and headings that clearly describe a topic. When users are skimming or hurrying through an action, this organization helps them avoid mistakes and unintentional actions.

_footer: Use headings and subheads to prioritize and group information_
_altText: Easily scannable content with different headings and subheadings on a card._

### Use sentence case

Unless otherwise specified, use sentence-style capitalization, where only the first letter of the first word in a sentence or phrase is capitalized. All text, including titles, headings, labels, menu items, navigation components, app bars, and buttons should use sentence-style capitalization.

Products and branded terms may also be capitalized.

_footer: Capitalize the first word of a sentence or phrase_
_altText: Sentence-style capitalization used for the title and consequence statement  in a dialog._

_footer: Don’t use title case capitalization. Instead, use sentence case._
_altText: Title casing used for the title  in a dialog._

### Use abbreviations sparingly

Spell out words whenever possible. Shortened forms of words can be difficult for people to understand and screen readers to read. Avoid Latin abbreviations in UI text such as e.g. or etc. Instead, use full phrases like "for example," or "and more."

_footer: When an abbreviation is appropriate, make sure it’s formatted and spelled correctly to avoid confusion_
_altText: AM and PM abbreviations used on a clock app._

_footer: Avoid using abbreviations when there’s space to spell out a word_
_altText: Abbreviations used for months and days on buttons when there is enough space to spell them out._

<!-- section: Word choice -->

## Pronouns

### Use second person pronouns ("you")

Use the second-person pronouns “you” and “your” to help the user to feel like the UI is talking to them and referring to their actions

_footer: Write from the user’s point of view to help them take action_
_altText: Offline error message saying "Your mail isn't available. Try checking your Wi-Fi connection."_

_footer: Avoid writing that sounds impersonal and robotic_
_altText: Offline error message saying "Mail not available."_

### Don’t combine first and second person

Avoid mixing "me" or "my" with "you" or "your.” It can cause confusion to see both forms of address in the same context.

_footer: Write from a user’s point of view by emphasizing their perspective with “you” and “your”_
_altText: "Your photos" is used in the description of a photo wall to emphasize the user's perspective._

_footer: Don’t mix different forms of address in the same screen. Instead, use “you” and “your” or get rid of the pronoun._
_altText: My' is used in the title and 'Your' in the description of a photo album._

### Use caution with “I” and “we”

When written on behalf of a large, global company like Google, “we” or “I” may come across as robotic or disconcerting. 

Focus on the user’s point of view, rather than Google’s, and consider if it’s possible to rewrite a phrase without “we.”

_footer: Don’t use first person pronouns to speak for the voice of Google_
_altText: "We're glad you're our customer" is the title of a survey by Google._

_footer: Avoid using first person pronouns. Write from the user’s point of view by using second person pronouns or removing pronouns altogether._
_altText: "My latest episode" and "My best match" are the titles used in a video app._

Some legal texts may merit an exception: “I” or “my” (the first person) emphasizes ownership in agreements or acknowledgments. For example, “I agree to the terms of service.”

_footer: First person pronouns can help users understand when they’re making impactful decisions_
_altText: "I agree" is used in the description of an agreement checkbox to emphasize on user's ownership._

_footer: Use caution with “we” or “our.” Even when these pronouns represent real people employed by Google, seeing first person pronouns in UI text can be confusing or jarring._
_altText: A part of Google ad message says, "Plus, we can assist with setting up your first campaign at no extra cost."_

<!-- section: Grammar and punctuation -->

This style guide is specific to English-language UX writing. Google generally follows [Associated Press (AP) style](http://www.apstylebook.com).

### Skip periods and unnecessary punctuation

To help readers scan text, avoid using periods and other unnecessary punctuation. 

Avoid using periods to end single sentences, particularly in:

-
Labels

-
Tooltip text

-
Bulleted lists

-
Dialog body text

-
Hyperlinked text

Use periods on:

-
Multiple sentences

-
Long or complex sentences, if it suits the context

_footer: Omit punctuation on single-line sentences_
_altText: Example of a period removed at the end of a short sentence on a snackbar._

_footer: Avoid using periods to end single sentences_
_altText: Example of a period used at the end of a short sentence on a snackbar._

### Use contractions

Contractions can make a sentence easier to understand and scan.

However, sometimes "do not" can give more emphasis than "don't” when caution is needed.

_footer: Avoid spelling out words that can be contractions_
_altText: Dialog with the title "You can't edit"._

_footer: Phrases that aren’t contracted can feel stiff or overly formal_
_altText: Dialog with the title "You cannot edit"._

### Use serial commas

Use the serial (or Oxford) comma, except before an ampersand.

Always place commas inside quotation marks.

_footer: Use a serial comma in lists of three or more items_
_altText: Serial comma used in an information text containing 3 items._

_footer: Don’t skip serial commas before “and”_
_altText: Serial comma not used in an information text containing 3 items._

### Use commas for numbers between 1,000 and 1 million

Use commas for numbers over 1,000. Don’t use commas when identifying something, such as a:

- Street address
- Radio frequency
- Year

For numbers over 1 million, comma use depends on context. “Million” can be abbreviated with with “M” and the value can be rounded when the intent is to give people a sense of the volume, rather than the exact numbers.

_footer: Abbreviate “million” with “M” and don’t use commas when giving people a sense of volume_
_altText: Music app showing song with 23 million views, which is abbreviated to 23M_

_footer: Use commas in numbers between 1,000 and 1 million_
_altText: Restaurant with 1,185 reviews, without abbreviation_

### Skip colons in headings

For headings on lists of items, do not use colons. For lists within body text, use a colon.

_footer: Use colons for lists within body text_
_altText: Colon used after the introduction statement for a list._

### Use exclamation points sparingly

Exclamation points can come across as shouting or overly friendly. Some exceptions include greetings or congratulatory messages.

_footer: Exclamation marks can be used to emphasize celebratory moments_
_altText: Exclamation mark used after "Congratulations"._

_footer: Avoid using exclamation marks for empty states and common tasks. Save it for bigger accomplishments._
_altText: Exclamation mark used after a general statement._

### Use ellipses sparingly

Use ellipses to indicate an action in progress or incomplete text. Truncated text may appear with ellipses, but check with your engineering partners before implementing, as this often happens automatically.

Don’t add a space before ellipses. Omit ellipses from menu items or buttons that open a dialog or start a process.

_footer: Ellipses show an action in progress_
_altText: A process indicator shows a 45% completion state._

_footer: Don’t use ellipses in buttons or menu items_
_altText: A button as part of a form has text saying "Saving" following by an ellipses._

### Use parentheses to define terms

Parentheses can be used to define acronyms or jargon or when referencing a source. They shouldn’t be used when adding a side note or an afterthought of a sentence.

_footer: Use parentheses to define terms and jargon_
_altText: Parentheses used to define an acronym._

_footer: Don’t use parentheses to add extra thoughts. If information is needed, include it in the sentence without parentheses for easier scanning and improved comprehension._
_altText: Parentheses used for adding an additional thought to a statement._

### Skip ampersands in body text

The “&” symbol can be used instead of “and” in headlines, column headers, table headers, navigation labels, and buttons. However, when there’s room, spelling out “and” can improve readability and make scanning easier.

“And” should be spelled out in sentences and paragraphs, before the final item in a 3+ item list, and in email subject lines.

_footer: Ampersands can be used in headlines where there's limited space_
_altText: Ampersand used in a heading._

_footer: Avoid ampersands in email subject lines_
_altText: Ampersand used in an email subject line._

### Use dashes with caution

Dashes and hyphens can interrupt a sentence and lead to a fragmented experience, so they should be used with caution. There are three kinds of dashes:

-
Em dash: —

-
En dash: –

-
Hyphen: -

Em dashes are best avoided in UX writing, as they indicate a break in the flow of a sentence that could be simplified using a comma, period, or new sentence. 

Use an en dash without spaces to indicate a range, such as 9 AM–Noon.

_footer: Use an en dash without spaces for ranges_
_altText: En dash used for time range._

### Use hyphens with care

Hyphens can help readers better understand how words relate to each other by binding closely related words. They can also be used to represent negative numbers, such as -100. Spaces should never be used surrounding hyphens.

Refer to the [Associated Press (AP) style guidelines](http://www.apstylebook.com) if you are unsure whether an adjective or noun phrase needs a hyphen.

**Rule**
 | **Examples** | **Why** |
**Hyphenate adjective phrases** | Case-by-case basis
Best-in-class performance
Once-in-a-lifetime opportunity | When multiple words are used together as an adjective, they should be hyphenated  |
Cell phone number
Chocolate chip cookie | However, proper nouns and common, easily understood adjective phrases don't need to be, such as "cell phone number" or "chocolate chip cookie" |
**Hyphenate noun phrases**
A noun phrase is two or more words acting as a noun. These phrases are hyphenated in certain cases: | Sign-off
Drive-through
Go-ahead | Hyphenate a noun phrase if it contains a verb followed by an adverb |
Higher-up
Most-read | Hyphenate an adjective phrase that is functioning as a noun |
Jack-of-all-trades
Stick-in-the-mud | Some noun phrases, especially long or complicated ones, are always hyphenated |
**Don't hyphenate verb phrases**
A verb phrase is two or more words acting as a verb. These should not be hyphenated. |
Look out for falling rocks

Please drive in and drop off your car

Check in to the room when you arrive
 | Don't hyphenate a verb followed by an adverb or preposition if it's functioning as a verb phrase. For example, "check in" would not need a hyphen when used as a verb, such as "check in to the room," rather than as a noun, like "the next check-in." Also, note that since "in" is a part of the verb, it can't be combined with "to" to form "into," since check into doesn't mean the same as check in to. |

### Use italics sparingly

Italics typically aren't easy to read. When emphasizing text, use bold weight instead.  

However, italics can provide unique emphasis when applied to a single word or phrase, like a name or title.

_footer: Italicize a word or phrase_
_altText: Dialog with Home Laptop in italics while rest of supporting text is not italicized._

_footer: Don’t italicize a sentence_
_altText: Dialog with all supporting text in italics._

### Don’t use caps blocks 

Avoid using caps blocks altogether; they're not accessible.

_footer: Don't use caps block. Use sentence case for all product text._
_altText: UI for Maps showing description of a location with a single word in a caps block._

---

<!-- Source: m3.material.io · styles_spacing · updated 2026-07-17T05:30:24.800Z · CC-BY 4.0 (Google) -->

## Spacing

> Spacing is the distance around and between component and layout elements



<!-- section: Overview -->

-
Apply spacing tokens to the margins, padding, and gaps of a component, UI element, or layout

-
Adapt spacing to different values based on context, like mobile vs desktop, or density settings

-
The spacing system is measured on an 8dp scale, where **space100 = 8dp**

-
Spacing is applied to the flow of elements (horizontal, vertical), or in relation to the elements (leading, trailing, top, bottom, gap)

-
[More details on grid & spacing design principles](/m3/pages/grids-spacing)

_footer: Spacing should adapt to component size, layout, form factor, and other contexts_
_altText: Bottom padding of small and large buttons is space200 and space400. Leading padding is space300 and space600._

## Availability & resources

Type
 |
Resource
 |
Status
 |

Implementation
 |
Android Views (MDC-Android)
 |
Unavailable
 |

Jetpack Compose
 |
Available
 |

Web
 |
Unavailable
 |

## Spacing units

Spacing units follow an 8dp scale. Rather than defining every value, Material only defines the most recommended spacing unit values on the scale. The system can be extended to add more spacing units and patterns as needed. [More on spacing tokens](/m3/pages/spacing/tokens/)

_footer: Spacing units are are created as a multiplier from the baseline unit of 8dp, which is space100_
_altText: A spacing scale shows 2, 4, 6, and 8 at the bottom range and 48, 56, 64, and 72 at the top of the range._

### Component layouts

In **components**, spacing units define the padding and gaps between individual elements of a component, such as text, icons, and controls.

_footer: Spacing concepts for components:  - Vertical padding (top & bottom)  - Vertical gap  - Horizontal padding (leading & trailing)  - Horizontal gap_
_altText: Padding and gaps applied to a mobile layout and 2 components._

### Page layouts

In **layouts**, spacing units standardize the overall composition of the page, like where text, UI elements, and components go.

Layouts use:

-
Panes, spacers, and margins to structure the page

-
Padding and gaps to organize content within the panes.

_footer: Spacing concepts for layouts:  - Margin  - Top padding  - Horizontal padding (leading & trailing)  - Spacer (gap)  - Vertical gap_
_altText: Padding and gaps applied to a mobile layout and 2 components._

## Parts of spacing

Spacing has three categories: **padding**, **gaps**, and **margins**.

-
Padding: Space inside an element

-
Gap: Space between elements in a grid or container

-
Margins: Space outside an element

The position of the spacing can be **vertical**, **top**, **bottom**, **horizontal**, **leading**, or **trailing**.

-
**Leading** and **trailing** edges swap sides in right-to-left (RTL) languages. [More on RTL layout design](/m3/pages/bidirectionality-rtl)

For example, the [search](/m3/pages/search/specs) container has:

-
8dp vertical padding

-
8dp horizontal gaps

-
24dp horizontal margins (12dp when focused)

_footer: Search horizontal margins are 24dp by default to ensure accurate placement from the screen edge_
_altText: Default search spacing._

_footer: Search margins change to 12dp when focused, while the container padding and horizontal gaps remain the same_
_altText: Active search spacing._

### Padding

Padding is the spacing inside an element. It adds a buffer from the container edge to the content, like text and icons.

_footer: Padding can be horizontal or vertical, or on a specific edge: leading, trailing, top, or bottom_
_altText: Examples of each possible padding value._

### Gaps

Gaps are the spaces between elements in a grid or container. Horizontal gaps are between side-by-side elements, and vertical gaps are between stacked elements.

Use a **horizontal gap** and **vertical gap** for simple components where gaps are always the same size.

Complex components with many different gaps should define them by the elements on each side, like an **icon-label gap.**

_footer: Gaps can be horizontal, vertical, or defined by the elements around it_
_altText: Examples of each possible gap value._

### Margins

Margins are the spacing outside an element. They add a buffer between the element and the parent container or screen edge.

**Use padding & gaps before using margins:**

-
Material rarely uses margins in components; padding and gaps tend to apply spacing in a more uniform way

-
Only use margins to apply further spacing beyond the parent container’s padding, or in layouts

_footer: Margins can be horizontal or vertical, or on a specific edge: leading, trailing, top, or bottom_
_altText: Examples of each possible margin value._

_footer: Define padding and gaps on the parent container to organize all elements inside_
_altText: Button with uniform container horizontal padding._

_footer: Avoid defining margins on child elements as they usually aren’t uniform, and require more tokens_
_altText: Button icon with different leading and trailing margin values._

<!-- section: Applying spacing -->

Material’s spacing system is intentionally designed to be a simple linear scale. Unlike the color system, which adjusts light and dark theme logic across all components at once, tailored spacing logic is built within each component.

_footer: Components have padding tokens that map to system tokens, which resolve to final values_
_altText: Component and system token mapping for the leading padding of three different icon buttons._

## What to use

### Pre-tokenized components

Some Material components map to spacing system tokens out of the box. This mapping can be customized by products to adapt to form factor or density.

Note: Work is ongoing to hook up all Material components to spacing tokens.

### System tokens

Spacing system tokens define the recommended values. Apply these to your product’s custom components and layouts, replacing any hardcoded values.

If the right system token doesn’t exist, [customize the system](/m3/pages/spacing/applying-spacing#f1a6df59-f03d-4949-b1e6-d2dd4422c730) and add your own.

_footer: Many Material components map to spacing system tokens_
_altText: Button with spacing tokens for all padding and gaps._

_footer: System tokens define all spacing values recommended by Material_
_altText: A list of spacing system tokens from 100 to 400._

### Spacing complements text scaling

When text is scaled up to 200%, the same spacing should be preserved by default.

_footer: Keep the same spacing when text scales_
_altText: A button with text scaled to 200% uses the same spacing tokens as an unscaled button._

## Customizing the system

The spacing system is meant to capture Material’s design intent, but customization is expected and often necessary. How you customize the system depends on your needs:

### Customize Material’s existing component spacing

Use this approach to customize how the base component appears across the entire product.

-
For example, change the “button top padding” mapping from **space125** to **space200** for a taller default button.

_footer: Customize component spacing to change it across the entire product_
_altText: A button’s vertical padding is changed from space125 to space200._

### Add custom system spacing & patterns

Use this approach when you need spacing units beyond what Material provides, or have common adaptive spacing patterns in your product.

-
Follow the multiplier pattern for new space tokens, so **space225 = 18dp** (8dp x 2.25).

-
Spacing patterns unique to your product can be tokenized.

-
For example, if cards and sheets adapt horizontal content padding the same way, you could create a **surface content horizontal padding** token for that pattern.

_footer: For products that adapt spacing the exact same way, consider creating a token for that pattern_
_altText: An outlined card and a bottom sheet both use the surface-content.padding.horizontal spacing pattern token._

### Add adaptive layout & density

Use this approach when you want the same core component, but want it to appear differently in specific situations, like screen sizes and density settings.

-
Adaptive layout: Map the spacing to different system tokens for each device type, such as mobile or desktop

-
Density: Adapt vertical padding to different spacing values for each setting

_footer: Components can be customized to adapt spacing to each form factor_
_altText: A button’s spacing changes based on if it’s on mobile, desktop, cars, XR, or TVs._

_footer: Components can be customized to adapt spacing to density settings_
_altText: A list item’s spacing changes based on density settings of 0 to -4._

<!-- section: Tokens -->

starNote:The spacing system tokens are only used on Jetpack Compose.

## System spacing tokens

System spacing tokens are a linear range of spacing values recommended by Material. They’re intended to cover the majority of spacing needs within the design system. The base unit of measurement **md.sys.measurement.space100** is **8dp**. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: The main spacing units are multiples of 8dp_
_altText: The spacing system tokens, built from 8dp (1x). The range covers 0x to 9x._

### Nested units

Values other than multiples of 8 are also used in layouts and Material components, like 2dp, 4dp, 6dp, and 10dp. Material only defines the most recommended nested units.

_footer: Material only defines nested units that are actively used in common layouts or Material components_
_altText: The spacing system defines tokens for 0.25x, 0.5x, 0.75x. 1.25x nested units._

## Component spacing

Most Material component spacing attributes will map to system spacing tokens. Spacing logic, like adaptive design or density, should be applied to the component attribute.

Component attributes follow a new naming strategy:

-
Going forward, all component spacing attributes will use **padding**, **margin**, and **gap**, and positional language: **horizontal**, **vertical**, **leading**, **trailing**, **top**, and **bottom**

Example: “Medium button: leading padding”

-
Past component spacing tokens use “**space**” to describe all padding, gaps, and margins, like **leading-space**, **trailing-space**, **top-space**, **bottom-space**, and **between-space**.

Example: “Medium button: leading space”

---

<!-- Source: m3.material.io · styles_elevation · updated 2026-07-17T05:03:59.318Z · CC-BY 4.0 (Google) -->

## Elevation

> Elevation is the distance between two surfaces on the z-axis



<!-- section: Overview -->

- Elevation is applied to all surfaces and components
- Tokens codify the distance on the z-axis to ensure components appear consistently relative to each other
- Tokens have no shadows or color; each platform determines the specific shadows and values to use at each elevation level
- Elevation can be shown as tonal surface colors or shadows
- Avoid changing the default elevation of Material 3 components
- Stick to using a small amount of elevation levels

Elevation is measured as the distance between components along the z-axis in density-independent pixels (dps).

_footer: Elevation represents the distance between elements. The product applies color to represent elevation.  - One surface at 1dp elevation and another surface at 8dp elevation, as viewed from the front  - The difference in elevation between the two surfaces is 7dp, as viewed from the side_
_altText: 1 diagram shows a light purple square and a darker purple square. A second one shows a side view of the squares in elevation, showing that the light square is lower in elevation than the dark square._

## Availability & resources

|
Resource
 |
Status
 |

Design
 |
[Design Kit (Figma)](https://www.figma.com/community/file/1035203688168086460)

 |
Available
 |

Implementation
 |
[Flutter](https://api.flutter.dev/flutter/material/ElevationOverlay-class.html)

 |
Available
 |
 |
[Jetpack Compose](https://developer.android.com/develop/ui/compose/designsystems/material3?_gl=1*zh4ff1*_up*MQ..*_ga*MTQ4NTEwOTIzLjE3NDA0MDY2Njk.*_ga_6HH9YJMN9M*MTc0MDQwNjY2OC4xLjAuMTc0MDQwNjY2OC4wLjAuNjU3NTAyNDY.#elevation)

 |
Available
 |
 |
[MDC - Android](https://github.com/material-components/material-components-android/blob/d56070586102b66486f7f8697de077c3d7689922/docs/theming/Color.md#using-surface-colors)

 |
Available
 |
 |
[MWC - Web](https://github.com/material-components/material-web/blob/919fe12badcfee4dcd72c390c0869dd8f996b51c/docs/components/elevation.md)

 |
Available
 |

## Differences from M2

- Shadows: Instead of applying shadows by default to all levels, use shadows only when required to create additional protection against a background or to encourage interaction
- Color: New color mappings and compatibility with dynamic color
- Levels: Elevation is now described in terms of levels

_footer: M2: Shadows applied at all levels_
_altText: Diagram of 2 concentric squares. The inner square is at 12dp and has a larger shadow than the outer square, which is at 3dp._

_footer: M3: Using color instead of shadows to communicate elevation_
_altText: Diagram of 2 concentric squares without shadows. Instead, the inner square is at level and tonally darker than the outer square, which is at level 2._

## All surfaces and components have elevation values

Surfaces at different elevations do the following:

-
Allow surfaces to move in front of and behind other surfaces, such as content scrolling behind app bars

-
Reflect spatial relationships, such as how a FAB's shadow indicates it's separate from a card collection

-
Focus attention on the highest elevation, such as a dialog temporarily appearing in front of other surfaces

_footer: Elevation can be depicted using shadows or other visual cues, such as surface fills with a tone difference_
_altText: 2 screens showing surfaces moving in front of and behind other surfaces, the shadow of a FAB, and a dialog appearing at the highest elevation._

### Resting elevation (default)

All components have a default resting elevation. Avoid changing the default elevation of Material components.

_footer: All components have a default elevation which should be used_
_altText: A floating action button with a shadow._

### Changing elevation

Components should change elevation in response to system events or user interaction, like hovering. This elevation change should be consistent across all similar elements.

For example, hovering a FAB temporarily increases the elevation by 1 level, from level 3 to level 4. All Material buttons increase elevation by 1 level when hovered.

_footer: Hovering over a button increases its elevation to show user interaction_
_altText: FAB elevation from the top and side showing the button elevation changing from 5dp to 8dp on hover._

<!-- section: Applying elevation -->

Material 3’s elevation system is deliberately limited to just a handful of levels. This creative constraint means you need to make thoughtful decisions about your UI’s elevation story.

_footer: Material uses six levels of elevation, each with a corresponding dp value. These values are named for their relative distance above the UI’s surface: 0, +1, +2, +3, +4, and +5. An element’s resting state can be on levels 0 to +3, while levels +4 and +5 are reserved for user-interacted states such as hover and dragged._
_altText: Diagram showing the 5 elevation levels and their respective dp values._

## Depicting elevation

Elevation can be depicted using shadows or other visual cues, such as surface fills with a tone difference or scrims.

To successfully depict elevation, a surface must show:

- Surface edges, contrasting the surface from its surroundings
- Overlap with other surfaces, either at rest or in motion
- Distance from other surfaces

_footer: - Two overlapping surfaces with distinct tonal values - Two overlapping surfaces with the same tonal values separated via shadow - Two overlapping surfaces with the same tonal values separated via scrim_
_altText: 3 images. The first shows a violet square overlapping a white square. The second shows 2 overlapping squares with the same color, but with shadows beneath the top square. The third shows a violet square overlapping a dark gray square._

### Tonal difference

Tonal difference between surfaces helps to express the tactile quality of Material surfaces. They show where one surface ends and another begins by separating different parts of a UI into identifiable components. For example, the edges of an app bar show that it's separate from a grid list, communicating to the user that the grid list scrolls independently of the app bar.

By default, Material 3's surfaces use tonal difference to indicate separation. Other methods can be used to indicate edges, such as:

-
Giving surfaces a drop shadow

-
Placing a scrim behind a surface

_footer: - A FAB's elevation helps separate it from body content  - A scrim appears below a modal to communicate importance  - Tonal differences between a navigation bar and body content indicate separate surfaces_
_altText: Elevation, scrim, and tonal differences used to indicate separation._

For interactive components, edges must create sufficient contrast between surfaces (by meeting or exceeding accessible contrast ratios) for them to be seen as separate from one another.

_footer: Ensure floating elements have sufficient contrast with surfaces beneath_
_altText: FAB separated from the surface beneath it using a shadow._

_footer: Don't use colors with insufficient contrast. The relationship between surfaces must be clear._
_altText: FAB without shadows, insufficiently separated from the surface beneath it._

### Surface color roles & elevation

You can pick from a range of surface and surface container color roles. These roles are not tied to elevation, and provide flexibility for defining containment areas.

Any overlapping containment areas or components should have different color roles in order to visually communicate separation.

[More on surface color roles](/m3/pages/color-roles/tab-1#89f972b1-e372-494c-aabc-69aea34ed591)

_footer: - Surface - Surface container_
_altText: Diagram of email home screen with "1" indicating the list item background color and "2" indicating the navigation bar background color._

## Shadows

Shadows can express the degree of elevation between surfaces in ways that other techniques can't.

Both a shadow’s size and amount of softness or diffusion express the degree of distance between two surfaces. For example, a surface with a shadow that's small and sharp indicates a surface’s close proximity to the surface behind it. Larger, softer shadows express more distance.

_footer: Smaller, sharper shadows indicate a surface’s close proximity to the surface behind it_
_altText: Podcast app with each show displayed as a card separated from the background using small dark shadows._

_footer: Larger, softer shadows express more distance between a surface and the one behind it_
_altText: Podcast app with each show displayed as a card separated from the background using more fuzzy and diffused shadows._

When it comes to applying shadows, less is more. The fewer levels in your UI, the more power they have to direct attention and action.

### When to use visible shadows

#### **Protect elements**

When a background is patterned or visually busy, the hairline style might not provide sufficient protection. In these cases, use elevation to separate and emphasize elements such as cards, chips, or buttons.

_footer: Interactive elements are emphasized with elevation_
_altText: Buttons with shadows separating them from a background image._

#### **Encourage interaction**

Elements can temporarily lift on focus, selection, or another kind of interaction, like swipe. A raised element can also lower when a higher element appears.

_footer: Elevation encourages interaction_
_altText: Screen in an email app in which sliding over an email card allows you to delete it._

## Scrims

A scrim can bring focus to specific elements by increasing the visual contrast of a large layered surface. Use the scrim beneath elements like modals and expanded navigation menus.

Scrims use the scrim color role at an opacity of 32%.

_footer: Scrims help bring focus to important elements like the navigation rail_
_altText: Large screen news app with a navigation rail separated from the body content by a scrim._

<!-- section: Tokens -->

## Tokens

Elevation levels can be implemented with tokens. Surface tint color is deprecated. Use elevation level tokens (0–5) instead. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Component elevation

Most components have a default elevation. Component elevation is only used to determine where the component sits in relation to other components, including when hovered or focused (which usually raises elevation by one level). Elevation has no shadow or value of its own by default.

Resting level
 |
Component
 |
DP Height
 |

5
 |
(not assigned as resting level) 
 |
12dp
 |

4
 |
(not assigned as resting level)
 |
8dp
 |

3
 |
Date pickers

Dialogs (modal)

Extended FAB

FAB

FAB menu (close button)

Search

Time pickers
 |
6dp
 |

2
 |
App bar (scrolled)

Menu

Navigation bar

Rich tooltip

Toolbar
 |
3dp
 |

1
 |
Banner

Bottom sheet (modal)

Button (elevated)

Card (elevated)

Chips (elevated)

Navigation drawer (modal)

Side sheet (modal)
 |
1dp
 |

0
 |
App bar (not scrolled)

Buttons (filled, tonal, outlined)

Button groups

Cards (filled, outlined)

Carousel

Chips

Dialog (full-screen)

Extended FAB (in navigation rail)

FAB (in navigation rail)

FAB menu (list items)

Icon buttons

List

Navigation rail

Segmented button

Side sheet (docked)

Slider

Split button

Tabs
 |
0dp
 |

---

<!-- Source: m3.material.io · styles_icons · updated 2026-07-17T05:07:23.551Z · CC-BY 4.0 (Google) -->

## Icons

> Icons are small symbols to easily identify actions and categories



<!-- section: Overview -->

-
Get Material Symbols icons at [fonts.google.com/icons](https://fonts.google.com/icons). Recolor, resize, and copy and paste icons.

-
Use the Material Symbols variable font to enable dynamic styling in product

-
You can change the weight, fill, optical size, and grade of variable font icons

_altText: Array of icons with various stylistic attributes._

## Resources

Type
 |
Link
 |
Status
 |

Design
 |
[Icons catalog](https://fonts.google.com/icons)
 |
Available
 |

[Material Symbols Figma plugin](http://goo.gle/material-symbols-figma)
 |
Available
 |

[Icon keyline template (ZIP)](https://storage.googleapis.com/material-io-design/downloads/gm_icon_template.ai.zip)
 |
Available
 |

## What's new

### Copy & paste customized Material Symbols

You can now copy and paste icons from [Google Fonts](http://fonts.google.com/icons). Once you search for and select the desired icon, options will appear in the right-hand panel to resize, recolor, and copy the customized icon to clipboard.

_footer: Icons can now be copied with a single click_
_altText: Panel showing options to size, recolor, and copy selected icon._

### Material Symbols

The new variable icon font set supports three styles: **outlined**, **rounded**, and **sharp**. All Material Symbols are newly drawn to be pixel-crisp and modernized.

_footer: - Outlined - Rounded - Sharp_
_altText: Twelve icons depicted in three styles: outlined, with rounded corners, and sharp._

### Adjustable axes

Material Symbols have four adjustable stylistic variable font attributes called **axes**. An axis refers to an attribute of a symbol that can be altered to create visual variations. The attributes are: weight, fill, optical size, **grade**.

_footer: A range of symbols shown with the same weight, fill, grade, and optical sizes_
_altText: Four icons shown with adjusted weight, fill, grade, and optical sizes._

### Material Symbols Figma plugin

Easily [incorporate Material Symbols](http://goo.gle/material-symbols-figma) into your latest designs on Figma.

_footer: Figma Symbols plugin_
_altText: Screenshot of Material Symbols plugin in Figma._

<!-- section: Designing icons -->

## Design principles

Icons are an essential element of any interface, packing an informative punch into a small form factor. They’re designed to be simple, modern, friendly, and sometimes quirky. To ensure consistency and readability, their limited size means that each icon must strictly adhere to guidance while still expressing essential characteristics.

_footer: Simplify icons for greater clarity and legibility_
_altText: Front view of boat icon._

_footer: Don’t be overly literal. Avoid complex icons._
_altText: Boat image with sails, mast, and flag._

_footer: Make icons graphic and bold_
_altText: Use geometric, consistent shapes._

_footer: Don’t use delicate or loose organic shapes_
_altText: Detailed thumbs-up icon with contoured fingers in outline._

_footer: Use and maintain a consistent visual style throughout one icon set_
_altText: Four icons with a consistent style._

_footer: Avoid mixing styles for one icon set_
_altText: Four icons with a inconsistent styles._

## Icon sizes and layout

### Standard (Baseline) icon size

Standard icons are displayed as 24dp x 24dp. For pixel-perfect accuracy, create icons for viewing at 100% scale.

_footer: 24dp grid at 100% scale_
_altText: Icon at 100% scale on a 24dp grid._

_footer: 24dp grid at 1000% scale_
_altText: Icon at 1000% scale on a 24dp grid._

### Additional optical icon sizes

Icons support additional sizes: 20dp, 40dp, and 48dp, with 20dp primarily for desktop, dense layouts, and small scale visuals, and 40dp and 48dp optimized for display or headline type, plus larger screen sizes.

_footer: Supported icon sizes: 20dp, 24dp, 40dp, and 48dp_
_altText: Four document icons shown at increasing scales._

### Standard (Baseline) icon layout

Icon content should remain inside of the **live area**, which is the region of an image that is unlikely to be hidden from view (such as an area where sidebars appear upon scrolling).

If additional visual weight is needed, content may extend into the padding between the live area and the **trim area** (the complete size of a graphic). No parts of the icon should extend outside of the trim area.

_footer: **Live area**  Icon content is limited to the 20dp x 20dp live area, with 2dp of padding around the perimeter_
_altText: A 24dp-by-24dp icon grid with the 20dp-by-20dp live area highlighted._

_footer: **Padding**  2dp of padding surrounds the live area_
_altText: A 24dp-by-24dp icon grid with the inner 2dp padding highlighted._

_footer: Icon content is limited to the 20dp-x-20dp live area, with 2dp of padding around the perimeter_
_altText: A 24dp-by-24dp icon grid with the inner 2dp padding highlighted._

_footer: If additional visual weight is needed, content may extend into the padding between the live area and the trim area_
_altText: Icon using live area and trim area._

_footer: No parts of the icon should extend outside of the trim area_
_altText: Icon exceeding trim area._

## Grid and keyline shapes

### Icon design template

If your design requires an icon that isn’t covered by the over 2,000 variations in [Google Font’s icon library](https://fonts.google.com/icons), you may want to create your own. [Download this 24dp keyline template](https://storage.googleapis.com/material-io-design/downloads/gm_icon_template.ai.zip)* (ZIP file) to design custom icons in Adobe Illustrator.

**This template is available under*[*Apache 2.0*](https://www.apache.org/licenses/LICENSE-2.0.html)*. By downloading this file, you agree to the*[*Google Terms of Service*](https://policies.google.com/terms)*. The*[*Google Privacy Policy*](https://policies.google.com/privacy)*describes how data is handled in this service.*

### Icon grid and keyline

The icon grid establishes clear rules for the consistent, but flexible, positioning of graphic elements. 

Keyline shapes are the foundation of the grid. By using these core shapes as guidelines, you can maintain consistent visual proportions across system icons.

_footer: Grid_
_altText: A 24dp-by-24dp icon grid._

_footer: 24dp grid at 1000% scale_
_altText: A 24dp-by-24dp grid of foundational icon keylines: square, circle, vertical rectangle, horizontal rectangle._

_footer: Square height and width, 18dp_
_altText: A 24dp-by-24dp grid of foundational icon keylines with the square keyline highlighted._

_footer: Icon drawn using square keyline_
_altText: Add chart icon on square keyline._

_footer: Circle diameter, 20dp_
_altText: A 24dp-by-24dp grid of foundational icon keylines with the circle keyline highlighted._

_footer: Icon drawn using circle keyline_
_altText: Globe icon on circle keyline._

_footer: Vertical rectangle height, 20dp, and width, 16dp_
_altText: A 24dp-by-24dp grid of foundational icon keylines with the vertical rectangle keyline highlighted._

_footer: Icon drawn using vertical rectangle keyline_
_altText: Document icon on vertical rectangle keyline._

_footer: Horizontal rectangle height, 16dp, and width, 20dp_
_altText: A 24dp-by-24dp grid of foundational icon keylines with the horizontal keyline highlighted._

_footer: Icon drawn using horizontal rectangle keyline_
_altText: Envelope icon on horizontal rectangle keyline._

_footer: Position icons “on pixel” within the icon grid_
_altText: Icon grid including a folder icon aligning to the grid. X and Y placement coordinates are shown using integers._

_footer: Don’t place the icon on a coordinate that isn’t “on pixel”_
_altText: Icon grid including a folder icon misaligned to the grid with X and Y placement coordinates shown using decimals._

## Icon metrics

### Anatomy

_footer: - Corner - Stroke terminal - Counter stroke - Stroke - Counter area - Bounding area_
_altText: Diagram of a calendar icon on a grid highlighting six different elements._

### Corners

Corner radii are 2dp by default. For the outlined style symbols, interior corners are square, not rounded. For shapes 2dp wide or less, stroke corners shouldn’t be rounded.

For the rounded style symbols, both exterior and interior corner radii are rounded and for the sharp style symbols, both exterior and interior corners radii reduce from 2dp to 0dp.

_footer: Exterior corners with 2dp corner radii_
_altText: Credit card symbol placed on grid with 2dp rounded exterior corners highlighted._

_footer: Interior corners shouldn’t be rounded_
_altText: Credit card symbol placed on grid with 2dp linear interior corners highlighted._

_footer: Overly round corners reduces the symbol’s legibility_
_altText: Document icon placed on grid with overly rounded corners highlighted._

_footer: Don’t use inconsistent corner radii_
_altText: ‘Add more’ icon placed on grid with inconsistent rounded corners._

### Weight and stroke

The recommended stroke weight for icons is 2dp or the regular weight (400), which includes curves, angles, and both interior and exterior strokes. Material Symbols can provide a range of weights between thin (100) and bold (700).

_footer: Timer icon at the regular stroke weight (400)_
_altText: Regular stroke weight timer icon placed on a grid._

_footer: Timer symbol shown across a 100–700 weight range_
_altText: Weight timer symbols ranging from 100 to 700 weight._

_footer: Stroke terminal on an icon_
_altText: Arrow symbol placed on a grid with arrowhead terminals trimmed to 45 degrees highlighted._

_footer: Counter stroke on an icon_
_altText: Add circle symbol placed on grid with linear 2dp inner stroke highlighted._

_footer: Use consistent stroke weights and squared stroke terminals_
_altText: Add chart icon placed on grid with consistent stroke weights and squared stroke terminals._

_footer: Don’t use inconsistent stroke weights or rounded stroke terminals_
_altText: Add chart icon placed on grid showing inconsistent stroke weights and rounded stroke terminals._

### Complex icon shapes

If an icon requires complex details, subtle adjustments can be made to improve its legibility. These adjustments are referred to as optical corrections. Any optical correction should use the geometric forms on which all other icons are based, without skewing or distorting those shapes.

_footer: The paperclip icon uses 1.5dp of the possible 2dp stroke area to fit multiple curves within the 24dp x 24dp icon space_
_altText: Paperclip icon on grid with adjusted 1.5dp stroke highlighted._

_footer: The ramen bowl icon uses 1.5dp stroke and 2dp stroke together within the 24 x 24dp icon space_
_altText: Ramen bowl icon on grid with adjusted 1.5dp stroke highlighted._

_footer: Make icons face forward_
_altText: Building icon using flat shapes._

_footer: Don’t tilt, rotate, or make icons appear dimensional_
_altText: Building icon in isometric perspective._

<!-- section: Applying icons -->

## Icon & Material Symbol styles

Material Symbols are the new default, and are available in three styles: **outlined, rounded,**and**sharp**. (The legacy Material Icons continue to be available, but don’t have the variable font capabilities of Material Symbols.)

### Outlined style

Outlined symbols use stroke and fill attributes for a light, clean style that works well in dense UIs. The stroke weight of outlined icons can be adjusted to complement or contrast the weight of your typography.

_footer: Outlined style_
_altText: Examples of outlined symbols with stroke and fill attributes._

_footer: 2dp outlined icons remain readable across sizes and applications_
_altText: Outlined icon set on grid._

_footer: For optimal legibility and recognition, some symbols should remain filled, such as full body human icons or proprietary icons_
_altText: Four filled symbols showing full body human and proprietary icons._

_footer: The lighter stroke weight of these outlined symbols mirrors the thin lines of the app’s typography_
_altText: Thin-lined outlined symbols correspond to app typography._

### Rounded and sharp styles

Rounded symbols use a corner radius that pairs well with brands that use heavier typography, curved logos, or circular elements to express their style.

Sharp symbols display corners with straight edges, for a crisp style that remains legible even at smaller scales. These rectangular shapes can support brand styles that aren’t well-reflected by rounded shapes.

_footer: Rounded-style icons_
_altText: Examples of rounded-style icons._

_footer: Sharp-style icons_
_altText: Examples of sharp-style icons._

_footer: Corner radii for round icons_
_altText: Plus icon as a round icon._

_footer: Square corner radii for sharp icons_
_altText: Plus icon as a sharp icon._

_footer: This app uses rounded buttons and round icons_
_altText: Travel app with rounded buttons and rounded icons._

_footer: The 0dp corner radius of the sharp icon set echoes this app’s rectangular design details_
_altText: Six icons implementing sharp style._

## Customizing Symbols

Material Symbols have four adjustable stylistic variable font attributes called **axes**. An axis is a typographic term referring to the attribute of a symbol that can be altered to create visual variations. 

Each style symbol contains four axes: **weight, fill, grade,** and **optical size**.

### Weight

Weight defines the symbol’s stroke weight, with a range of weights between thin (100) and bold (700). Weight can also affect the overall size of the symbol.

_footer: A symbol in a range of weights_
_altText: Gradual increase of symbols from thin to bold._

_footer: 400 regular-weight symbols_
_altText: 400 regular-weight icons used in standard navigation drawer and modal navigation drawer._

_footer: Don't use the lightest weight for standard-size (24dp) icons. The minimum weight for this size should be 200._
_altText: Photo gallery using 100 weight icons._

_footer: Be careful using excessive weight for standard 24dp symbols_
_altText: Three side-by-side 24p standard symbols._

_footer: Apply weights consistently_
_altText: Navigation rail with consistent symbol weights._

_footer: Don’t mix different weights_
_altText: Navigation rail with varying symbol weights._

### Fill

Fill gives you the ability to transition from a more outlined style to a reversed or more filled style.

A fill attribute can be used to convey a state of transition, such as unfilled and filled states. Values range from 0 to 1, with 1 being completely filled. Along with weight, fill is a primary attribute that impacts the overall look of a symbol.

_footer: Unfilled symbols with fill set to 0_
_altText: Unfilled icons._

_footer: Filled symbols with fill set to 1_
_altText: Set of filled icons._

_footer: Bottom navigation with filled symbols in selected and unselected states_
_altText: Four filled symbols in selected and unselected states set in bottom navigation._

### Grade

Weight and grade affect a symbol’s thickness. Adjustments to grade are more granular than adjustments to weight and have a smaller impact on the size of the symbol.

Grade is also available in some text fonts. Grade levels between text and symbols can be matched for a harmonious visual effect. For example, if the text font has a -25 grade value, the symbols can match it with a suitable value of -25.

_footer: - At grade 0, the thickness of the symbol does not change - At negative grade, the thickness of the symbol appears lighter_
_altText: Symbol thickness at grade 0 and at negative grade._

Grade can also compensate for**visual bleed**, which is when images can look bigger or smaller depending on the color contrast. To match the apparent icon size, the default grade for a dark icon on a light background is 0, and -25 for a light icon on a dark background.

_footer: Icon button featuring a 0 default grade symbol in light UI_
_altText: Button with icon and text in light UI._

_footer: Icon button featuring a negative grade symbol in dark UI_
_altText: Button with icon and text in dark UI._

To make strokes heavier and more emphasized, use positive value grade, such as when representing an active icon state.

_footer: An icon with active state using positive value grade for emphasis_
_altText: Photo icon in active state appearing bolder._

### Optical sizes

Optical sizes range from 20dp to 48dp.

For the image to look the same at different sizes, the stroke weight (thickness) changes as the icon size scales. Optical size offers a way to automatically adjust the stroke weight when you increase or decrease the symbol size.

_footer: Four optical sizes, 20dp, 24dp, 40dp, 48dp_
_altText: Four icons gradually increasing in optical size._

Traditionally, icons are resized from a 24dp source vector, resulting in a large scaled icon that’s too heavy compared to the original. With the optical size axis, you can maintain the stroke weight (thickness) as the icon size grows.

_footer: - Material icon  - Material Symbol_
_altText: Side-by-side scaling view showing a Material icon and a Material Symbol._

_footer: Use 20dp optical size value for dense layouts on desktop_
_altText: Desktop dropdown menu with icon in active state._

_footer: Use larger size 40dp–48dp symbols when primary actions need to be highlighted_
_altText: Forward and reverse symbols highlighted on device._

## Using Material Symbols with typography

Material Symbols are designed with similar considerations to typefaces, and often appear alongside text. Choosing the right icon set can tie the content of an interface together, enhancing the cohesive branded feel of your product.

_footer: Match the optical weight and size of text and icon to ensure consistency_
_altText: Selections of icons and typography examples in different contexts where weights and sizes are paired._

_footer: Use the same size for your Material Symbols and text_
_altText: Text and icon that are the same size._

_footer: Don’t mix the sizes of your symbol and text_
_altText: A small icon mismatched with larger text._

_footer: Use the same optical weight for your symbol and text_
_altText: An icon and text that are the same optical weight._

_footer: Don’t use different optical weights for Material Symbols and text_
_altText: An icon and text that have mismatched optical weight._

_footer: Shift down the baseline of symbols to approximately 11.5% of the text size_
_altText: Icon that has had its baseline shifted down 11.5%._

_footer: Don’t use the same baseline for Material Symbols and text_
_altText: Icon and text that are using the same baseline._

## Accessibility

Learn more about making your icons more accessible.

### Icons with a label text

Label text provides short, meaningful descriptions when symbols are more abstract. This can prove helpful in the case of navigation.

_footer: Label text provides short descriptions, especially useful for navigation_
_altText: Navigation bar showing four destinations, with 1 active destination featuring both icon and text label._

_footer: Use caution if icons are displayed without labels. Icon meaning should always be unambiguous and accessible for all users. Text labels can be omitted in specific circumstances where reduced visual impact is necessary._
_altText: Navigation bar with four destinations with only icons, no labels._

### Small icons

Material Symbols can scale up or down in size without a loss of fidelity. Simple symbols, like stars for ratings, can be used on their own at any size, as long as they remain identifiable.

Other symbols should have an accompanying text label below 20dp to ensure their meaning is clear and to maintain accessibility. These symbols include:

- Complex icons, which are highly detailed or have multiple parts
- Icons with a key action, which are essential to using the product

### Target size

Adequate space should surround icons to allow legibility and interaction.

Symbols of 24dp should have a target size of 48dp by default.

_footer: - Measurements - Placement_
_altText: 1. 24dp add symbol inside 48dp red square, 2. mobile UI with attach, add, and more symbols._

When a mouse and keyboard are the primary input methods, measurements may be condensed to accommodate denser layouts.

A 20dp size symbol can use a target size of 40dp.

_footer: - Measurements - Placement_
_altText: 1. 24dp add symbol inside 48dp red square, 2. desktop UI with attach, add, and more symbols._

## Localizing icons

To make sure iconography translates effectively in local markets, test it across age groups, cultures, and languages, and follow these best practices:

- Use labels when icons and symbols are more abstract
- Remember that navigation items must have labels for clarity and accessibility
- Consider tech knowledge: people who use the internet a lot may have different understandings of icons than people who use the internet less

_footer: Translate icons for local markets. For example, different locales may prefer a cart, bag, or basket for checkout experiences._
_altText: Comparison of three UIs showing add to cart, add to bag, and add to basket._

### Cultural influence of colors and symbols

Color carries cultural significance and can convey different emotions in different cultures. White is commonly associated with purity in western cultures but symbolizes mourning in some eastern cultures.

Consider cultural interpretations of symbols. In many western cultures, owls represent wisdom, while some eastern cultures view them as a negative omen. When using or creating symbols, be mindful that their meanings can vary significantly across cultures.

_footer: Think about how color translates. Some locales use red as a warning color, while others use green._
_altText: Comparison of UIs where red and green are warning colors._
