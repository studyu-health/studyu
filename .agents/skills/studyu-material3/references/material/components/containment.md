# Material 3 · Containment

<!-- Source: m3.material.io · components_cards · updated 2026-07-24T06:14:10.548Z · CC-BY 4.0 (Google) -->

## Cards



<!-- section: Overview -->

-
Use cards to contain related elements

-
Three variants: elevated, filled, outlined

-
Contents can include anything from images to headlines, supporting text, buttons, and lists

-
Can also contain other components

-
Cards have flexible layouts and dimensions based on their contents

_footer: - Elevated card - Filled card - Outlined card_
_altText: 3 variants of cards_

## Availability & resources

## Differences from M2

-
Color: New color mappings and compatibility with dynamic color

-
Elevation: Lower elevation and no shadow by default

-
Variants: Three official card variants – elevated, filled, and outlined

_footer: Cards have updated colors, elevation, and variants_
_altText: M3-style card_

<!-- section: Specs -->

## Tokens & specs

Select a component variant below to see its elements, attributes, tokens, and their values.

## Elevated card

_footer: - Container_
_altText: Diagram indicating elevated card container._

### Elevated card color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Elevated card color roles used for light and dark themes:  - Surface container low_
_altText: Color diagram indicating elevated card surface color._

### Elevated card states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states)

_footer: Elevated card states:   - Hovered - Focused - Pressed - Dragged - Disabled_
_altText: Diagram of 5 elevated card states._

## Filled card

_footer: - Container_
_altText: Diagram indicating filled card container._

### Filled card color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Filled card color roles used for light and dark themes:  - Surface container highest_
_altText: Color diagram indicating filled card surface color._

### Filled card states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states)

_footer: Filled card states:   - Hovered - Focused - Pressed - Dragged - Disabled_
_altText: Diagram of 5 filled card states._

## Outlined card

_footer: - Container - Outline_
_altText: Diagram indicating outlined card container and outline._

### Outlined card color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Outlined card color roles used for light and dark themes:  - Surface - Outline variant_
_altText: Outlined card color roles in light and dark themes._

### Outlined card states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states)

_footer: Outlined card states:   - Hovered - Focused - Pressed - Dragged - Disabled_
_altText: Diagram of 5 outlined card states._

## Measurements

_footer: Card padding and size measurements_
_altText: Diagram with card layout measurements._

Attribute
 | Value
 |
Shape
 | 12dp corner radius |
Left/right padding
 | 16dp |
Padding between cards
 | 8dp max |
Label text alignment
 | Start-aligned |

<!-- section: Guidelines -->

_altText: 3 variants of cards: elevated, filled, and outlined._

## Usage

Use a card to display content and actions on a single topic.

Cards should be easy to scan for relevant and actionable information. 

Elements like text and images should be placed on cards in a way that clearly indicates hierarchy.

_footer: Cards can display content and actions on a single topic_
_altText: Example card containing an image, title, text, and button._

Cards can serve as entry points into deeper levels of detail or navigation, such as a music album or details on an upcoming vacation.

_footer: Card text and image show a clear hierarchy_
_altText: Example world tour card._

_footer: Use cards to display related information on a single subject_
_altText: Card displaying connected details about a world tour._

Cards can be displayed together in a grid, vertical list, or carousel.

_footer: Cards can be shown together_
_altText: 4 cards together in a grid layout._

_footer: Don't force content into cards when spacing, headlines, or dividers would create a simpler visual hierarchy_
_altText: 5 albums in a vertical list of cards._

There are three card variants:

-
Elevated

-
Filled

-
Outlined

Each provides the same legibility and functionality, so the variant you use depends on style alone.

_footer: - Elevated card - Filled card - Outlined card_
_altText: 3 variants of cards._

_footer: Elevated cards have a drop shadow, providing more separation from the background than filled cards, but less than outlined cards_
_altText: Example elevated card._

_footer: Filled cards provide subtle separation from the background. This has less emphasis than elevated or outlined cards._
_altText: Example filled card._

_footer: Outlined cards have a visual boundary around the container. This can provide greater emphasis than the other variants._
_altText: Example outlined card._

## Anatomy

The card container is the only required element in a card. Card layouts can vary to support the kinds of content they contain. Below is a common configuration of elements.

_footer: - Container  - Image  - Button  - Supporting text  - Subhead  - Headline_
_altText: Diagram labeling the 6 parts of card anatomy._

### Container

Card containers hold all card elements. Their size is determined by the space those elements occupy. Card elevation is expressed by the container.

The card container is the only required element of a card. All other elements are optional.

_footer: Card size is determined by the elements it contains_
_altText: 3 card containers with various elements: 1 with all elements except a button. 1 with a container, headline, supporting text, button. 1 with a container, headline, supporting text, 2 buttons._

### Content blocks

Card contents are grouped into blocks. Content can have different levels of visual emphasis depending on importance.

Card layouts vary to support the kinds of content they contain.

_footer: Cards can contain a headline, subhead, supporting text, media, and actions_
_altText: Diagram of card content blocks._

### Dividers

[Dividers](/m3/pages/divider/specs) can separate regions in cards or indicate areas of a card that can expand.

_footer: 1. Use full-width dividers for content that can be expanded_
_altText: A divider running the entire width of the card._

_footer: 1. Use inset dividers, which don’t run the full width of a card, to separate related content_
_altText: An inset divider indented from the edge of card._

### Media

**Thumbnail**
Cards can include thumbnails for an avatar or logo.

**Image**
Cards can include photos, illustrations, and other graphics, such as weather icons.

**Video**
Cards can include video.

_footer: Cards can contain thumbnails, images, and video_
_altText: A mobile chat app with: 5 cards with images, 1 card with a thumbnail avatar, and 1 card with a video._

### Text

**Headline**
Headline text often communicates the subject of the card, such as the name of a photo album or article.

**Subhead**
Subheads are smaller text elements, such as an article byline or a tagged location.

**Supporting text**
Supporting text includes body content, such as an article summary or a restaurant description.

_footer: Headline, subhead, and supporting text in a card_
_altText: card container with several elementsA tablet email app with an email summary card with multiple text elements._

#### Layering text, icons, and images

It isn’t recommended to place text or icons on images. If it’s necessary, ensure the background image provides sufficient contrast for the text to meet accessibility standards.

Add a translucent scrim or bounding shape beneath the text or icon to help ensure proper contrast.

_footer: Ensure that text on images meets accessible contrast standards_
_altText: Layered text contrasts with the background image._

_footer: When placing text or icons on images, consider using a bounding shape to ensure proper contrast_
_altText: Icon within a bounding shape, placed on an image._

### Actions

#### **Primary action area**

Cards can be one large touch target triggering an expanded detail screen.

_footer: Cards can include a primary action area that expands into a full-screen view_
_altText: The action area of a card contains rich media and supporting text._

**Buttons**
Cards can include buttons for actions such as **Learn more** or **Add to cart**.

**Icon buttons**
Cards can include icon buttons for actions such as **Save**, **Heart**, or **Leave a 4-star review**.

**Selection controls**
Cards can also include chips, sliders, checkboxes, and other selection controls.

**Linked text**
There can be a link in the supporting text on a card.

_footer: Cards can include multiple action areas containing buttons, links, and other controls_
_altText: Supplemental text and actions at the top and bottom of the card._

_footer: Cards can contain icon buttons like stars to rate content_
_altText: Album card with an option to give a star rating._

_footer: Cards can contain choice chips in the action area_
_altText: Card to purchase tickets with choice chips for 3 event times._

_footer: Cards can contain a slider control in the action area_
_altText: Card with slider to control a song’s volume._

Overflow menu
Overflow menus contain related actions. They are typically placed in the upper-right or lower-right corner of a card.

_footer: Overflow menus are usually located in the upper-right or lower-right corner of a card_
_altText: 2 cards: 1 with an overflow menu in the upper-right corner, the other with it in the lower right._

## Cards in a collection

Multiple cards can be grouped together into collections displayed in a grid, list, or carousel. 

By default, cards in a collection are coplanar. They share the same resting elevation unless they're picked up or dragged.

_footer: Multiple cards can be grouped into collections with a shared resting elevation_
_altText: 9 cards in a grid layout._

#### Filtering and sorting

Card collections can be filtered in a variety of ways, including by date or alphabetical order. If a collection can be filtered, the filter must apply to each card in the collection. 

Filter or sorting options should be placed outside of the card collection.

_footer: Card collections can be filtered in a variety of ways, including by date: 1. A sort-by-date option is placed outside of the card collection_
_altText: A sort-by-date option placed above a card collection._

Organize card collections so that they'e easy to use. Their layout affects how they are perceived.

_footer: Place cards in a collection in a straightforward, easy-to-use manner_
_altText: A template for an 8-card collection layout._

### Grid

Cards can be displayed together in a grid.

_footer: Cards displayed in a grid_
_altText: A set of 4 cards in a grid._

The default grid can be customized in code to show cards in staggered or mosaic grids.

_footer: Custom mosaic grid_
_altText: 5 menu item cards in a mosaic grid._

_footer: Custom staggered grid_
_altText: 4 menu item cards in a staggered grid._

### Vertical list

Cards can be displayed together in a vertical list.

_footer: Cards can be shown in a vertical list_
_altText: 3 cards in vertical list._

### Carousel

Cards can be displayed together in a horizontal row or carousel.

_footer: Cards displayed together in a horizontal row or carousel_
_altText: 3 event reservation cards in a horizontal row._

## Adaptive design

As cards scale to adapt to different [breakpoints](/m3/pages/breakpoints), their position and alignment can also change.

Cards and their elements can align left, right, or center as the layout scales.

_footer: Card position and alignment changes as the screen size changes_
_altText: 2 cards on a mobile screen row expand to 4 cards on a tablet screen row._

### Ergonomics

Adjust the layout of cards to meet the ergonomic needs of large screens. 

For example, a horizontally-oriented card in a compact breakpoint may become a larger, vertically-oriented card in an expanded breakpoint, with more space for images and text on the larger screen.

_footer: Adjust the card layout so content remains the main focus on large screens_
_altText: Card sizes change from mobile to tablet, with larger images in the tablet layout._

### Visual presentation

To adjust the presentation of content-focused components, begin with spacing. 

Allow components like lists, cards, and images to optimize space while filling the region of a screen that suits a device breakpoint’s ergonomic needs.

_footer: Spacing adjusts for components such as cards, lists, and images_
_altText: 2 cards with optimized space: 1 narrow rectangle, 1 wide square._

_footer: Example of the same card with two different orientations and element positioning_
_altText: 2 examples of the same card: 1 vertical with an image at the top, 1 horizontal with an image on the left._

### Column-based layouts

In mobile layouts, components such as lists or cards are stretched to fit the full width of the screen without compromising visual quality or user experience. When designing for large screens with an expanded breakpoint, use multiple columns to display content.

Avoid extending UI elements across the screen when possible. On larger screens, rearrange groups of related cards into horizontal rows or carousels, to allow for better content organization.

_footer: When designing for large screens, use multiple columns to display content_
_altText: 3 related cards in a carousel._

### Small screens

On smaller screens with the compact breakpoint, consider swapping cards for lists, which can display images and text in a more compact form. 

Make sure that controls, actions, and other component-specific elements are maintained.

_footer: Certain devices or user contexts require different components to meet platform expectations_
_altText: Cards on a large screen adapt to a list on a small mobile screen._

## Behavior

### Expanding

Cards can use a [container transform](/m3/pages/motion-transitions/transition-patterns#b67cba74-6240-4663-a423-d537b6d21187) transition pattern to reveal additional content. Reserve this pattern for hero moments that are meant to be expressive.

_footer: A card expands to fill the full screen using a parent-child transition_
_altText: An album card expands to fill the screen and shows additional related content._

_footer: Expand a card to reveal information_
_altText: A card expands, showing all content at once._

_footer: Don’t scroll within a card to reveal information_
_altText: A card expands, internally scrolling to only show some information._

### Navigation

Cards can use a [forward and backward](/m3/pages/motion-transitions/transition-patterns#df9c7d76-1454-47f3-ad1c-268a31f58bad) transition pattern to navigate between screens at consecutive levels of hierarchy. This pattern has a simpler motion style compared to container transform, which makes it suitable for common navigation transitions.

_footer: Cards can use a forward and backward transition pattern to navigate between screens_
_altText: Card interaction transitioning to full screen._

### Gestures

#### Swipe

A swipe gesture can be performed on a single card at a time, anywhere on that card.

It can be used to:

- Dismiss a card
- Change the state of a card, such as flagging or archiving it

_footer: A card should only have one swipe action assigned to it_
_altText: A card with 1 assigned swipe: to heart the entire card._

_footer: Cards shouldn’t contain content that can be swiped, such as an image carousel or pagination. Also, swipe gestures shouldn’t cause portions of cards to detach upon swiping._
_altText: A card with an image carousel and a swipe motion to heart only the bottom text on the card._

#### Pick up & move

The pick-up-and-move gesture allows users to move and reorder cards in a collection.

_footer: When moving a card, increase its elevation_
_altText: A card is elevated above all other cards when moved._

_footer: Don’t let cards bump other elements out of the way. When a card is picked up, it appears in front of all elements, except app bars and navigation._
_altText: A moved card bumps other cards around, and isn’t elevated above them._

#### Scrolling

Card content that’s taller than the maximum card height is truncated and doesn’t scroll, but can be displayed by expanding the height of a card.  

A card can expand beyond the maximum height of the screen, in which case the card scrolls within the screen.

_footer: On a mobile device, cards can expand to reveal more content, scrolling within the screen. Content within cards doesn’t scroll._
_altText: Scrolling a page with an expanded card._

_footer: On a mobile device, cards can't internally scroll, as it could cause two scroll bars to be displayed_
_altText: Expanded card on mobile with internal scrolling._

#### Scrolling on desktop

On a desktop device, card content can expand and scroll within a card.

_footer: On a desktop, content can expand and scroll within a card_
_altText: Expanded card on desktop with internal scrolling._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Navigate to a card and the elements within a card
- Get appropriate feedback based on input type documented under [Interaction & style](/m3/pages/cards/accessibility#ce764d54-6b59-42db-807f-b3cb370eecdb)

## Interaction & style

A card can be a non-actionable container that holds actions like buttons and links, or it can be directly actionable without any buttons or links. This is to avoid stacking actionable elements. An action shouldn’t be placed on an actionable surface.

_footer: - Non-actionable card with buttons - Directly actionable card with no buttons_
_altText: 2 possible card interaction behaviors._

### Touch

When a user taps on a directly actionable card, a touch ripple appears across the card, indicating feedback. 

Non-actionable cards don’t ripple.

_footer: Touch: Tap_
_altText: Ripple effect created when tapping on a card._

### Dragging and dismissing

To meet Material's accessibility standards, any dragging and swiping interactions need a single-pointer alternative, like selecting the same actions from a menu.

For example, tapping a card, or pressing and holding, should open a menu to change its position in a list. That menu could also contain an action to delete the card.

_footer: Use containers like bottom sheets or menus to show single-pointer options_
_altText: A list of cards has its order reshuffled using a single-pointer option._

It isn’t recommended to place menus on top of the card on the draggable state. If doing so is necessary, ensure that the interaction can be completed.

_footer: Ensure that the menu doesn't cover the card_
_altText: A menu over a card that doesn't totally obscure the card._

### Cursor

When a directly actionable card is hovered, the hover state provides a visual cue to the person that the element is interactive. Non-actionable cards don’t have a hover state.

When a directly actionable card is clicked, a ripple appears, providing feedback.

_footer: Cursor: Hover, Click_
_altText: Hover state and touch ripple effect of a card._

### Keyboard

A focus indicator appears around actionable elements when tabbing through cards. This provides a visual cue to a person that the destination is now focused and an action can be taken.

A person can **Tab** to navigate between actionable elements of the cards. If the cards are non-actionable, **Tab** navigates directly to the actionable buttons or links within the cards.

When engaging with a focused actionable card or element using the **Space** or **Enter** key, an action is performed or a secondary action is available, such as a menu.

Within the menu, a person is able to **Arrow** through the menu items, **Space** or **Enter** to select an item, or **Tab** to exit.

_footer: Keyboard: Tab, Arrows_
_altText: Navigating cards with a keyboard._

## Focus

All interactive elements of cards need a tab stop so they can be focused. Directly actionable cards are tab stops.

For non-actionable cards, the card itself is not a tab stop. However, every actionable element in the card is a tab stop so they’re all visited before focus navigates to the next card.

_footer: Use **T****ab** to navigate through all buttons in a card_
_altText: The focus areas of a card with interactive elements._

_footer: Card layouts can change on different devices_
_altText: Cards forming a list on mobile and cards forming a gallery on tablet._

## Keyboard navigation

Keys | Actions |
**Tab** |
Move to the next actionable element

**Directly actionable cards:** Move to next card container

**Non-actionable cards with actionable elements:** Move to next actionable element
 |
**Space** or **Enter** | Confirm action |

## Labeling elements

The informative contents of a card are verbalized when navigating to them using a screen reader. If an image in a card is purely decorative, hide it from screen readers. All actionable elements must receive both screen reader and keyboard focus.

Directly actionable cards can have the **button** or **link** role, depending on how they’re used. 

Non-actionable cards are purely containers, so they don’t need a role.

_footer: Non-actionable card elements are navigable, focused in order, and verbalized when in focus. In this example, the order is:  - Heading - Image - Body text - Primary button - Secondary button_
_altText: Card elements annotated in the order that a screen reader tabs through them._

---

<!-- Source: m3.material.io · components_carousel · updated 2026-08-18T17:48:11.944Z · CC-BY 4.0 (Google) -->

## Carousel



<!-- section: Overview -->

-
Contain visual items like images or video, along with optional label text

-
Six layouts: Multi-browse, uncontained, uncontained multi-aspect ratio, hero, center-aligned hero and full-screen

-
Layouts can be start-aligned or center-aligned

-
Item visuals have a parallax effect when scrolled

-
Items change size as they move through the carousel

_footer: Carousels can show items of various sizes_
_altText: A carousel being scrolled horizontally. Each carousel item changes shape as it scrolls._

## Availability & resources

## Updates

**November 2025**

New carousel layout:

-
Uncontained multi-aspect ratio

**2023**

Additional layouts and configurations:

-
Uncontained

-
Full-screen

-
Centered carousels

-
Hero carousel layout

-
Multi-browse layout

_footer: New carousel layout: uncontained multi-aspect ratio_
_altText: Items of different widths in an uncontained multi-aspect ratio layout._

## Differences from M2

This component is new in Material 3.

- **Shape**: Dynamic carousel items change shape when scrolled
- **Motion**: Carousel items move at a different speed than their content, creating a parallax effect
- **Interaction**: When scrolled, carousel items snap into place to maintain the same layout. Hero carousels swipe through one item at a time. Multi-browse carousels scroll through many items at once.

_footer: Hero carousels scroll through one large item at a time_
_altText: Carousel in a contained layout with a large item and a small item._

## Research

The Material Research Team conducted two studies (quantitative and qualitative) with over 200 participants to understand their perspectives of five different carousel designs. The studies measured their understanding of how to interact with each carousel, their expectations of the number of items in each design, and how they expected carousels to be used.

**Summary of findings:**

-
Participants thought carousels were a good way to explore many different kinds of content

-
A previewed or squished item strongly indicated that there was more content to swipe through

-
Participants expected around 10 items in a carousel that scrolled multiple items at once

-
While some contexts were considered better for some carousel designs, all designs were considered similarly usable

<!-- section: Specs -->

_footer: - Container - Large carousel item - Medium carousel item - Small carousel item_
_altText: 4 elements of a carousel._

## Tokens & specs

Browse the component elements, attributes, tokens, and their values.

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Carousel color roles used for light and dark schemes:  - Container - Surface_
_altText: 2 color roles of a carousel._

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: - Enabled - Hovered - Focused - Pressed - Disabled_
_altText: 5 states of a carousel in light and dark schemes._

## Carousel item dynamic widths

All kinds of carousel items dynamically adapt to the width of the container.

Large items have a customizable maximum width that's used to optimally fit carousel items into the available space.

Small carousel items have a minimum width of 40dp and a maximum width of 56dp.

Items change size as they move through the carousel layout.

_footer: Small carousel items have a minimum and maximum width_
_altText: Measurements for a small carousel item._

## Multi-browse

The multi-browse layout shows at least one large, medium, and small carousel item.

_footer: - Container - Large carousel item - Medium carousel item - Small carousel item_
_altText: 4 elements of a multi-browse carousel layout._

### Measurements

_footer: Multi-browse carousels have padding on both sides of the container_
_altText: Measurements of a multi-browse carousel layout._

Attribute | Value |
Alignment | Vertically centered |
Leading/trailing padding | 16dp |
Top/bottom padding
 | 8dp |
Padding between elements
 | 8dp |
Large item width | Dynamic, or user-set |
Medium item width | Dynamic |
Small item width | 40–56dp, dynamic |
Item corner radius | 28dp |

## Uncontained

The uncontained layout shows items that scroll to the edge of the container.

_footer: - Container - Large carousel item_
_altText: 4 elements of an uncontained carousel layout._

### Measurements

_footer: Uncontained carousel items bleed over the padding on each side when scrolling_
_altText: Measurements of an uncontained carousel layout._

Attribute | Value |
Alignment | Vertically centered |
Leading padding | 16dp |
Top/bottom padding
 | 8dp |
Padding between elements
 | 8dp |
Item corner radius | 28dp |

## Uncontained mutli-aspect ratio

The uncontained multi-aspect ratio layout shows carousel items of various widths.

_footer: - Container - Carousel item (16:9) - Carousel item (9:16) - Carousel item (1:1) - Carousel item (3:4)_
_altText: 4 elements of an uncontained carousel layout_

### Measurements

_footer: Uncontained multi-aspect ratio carousels only have leading padding, with 8dp of padding between items._

Attribute | Value |
Alignment | Vertically centered |
Leading padding | 16dp |
Top/bottom padding
 | 8dp |
Padding between elements
 | 8dp |
Item corner radius | 28dp |

## Hero

The hero layout shows at least one large item and one small item.

_footer: - Container - Large carousel item - Small carousel item_
_altText: 3 elements of a hero carousel layout._

### Measurements

_footer: Hero carousels have padding on both sides of the container_
_altText: Measurements of a hero carousel layout._

Attribute | Value |
Alignment | Vertically centered |
Leading/Trailing padding | 16dp |
Top/bottom padding | 8dp |
Padding between elements | 8dp |
Large item width | Dynamic |
Small item width | 40-56dp, dynamic |
Item corner radius | 28dp |

## Center-aligned hero

The center-aligned hero layout shows at least one large item and two small items.

_footer: - Container - Large carousel item - Small carousel item_
_altText: 3 elements of a center-aligned hero carousel layout._

### Measurements

_footer: Center-aligned hero carousels have padding on both sides of the container_
_altText: Measurements of a center-aligned hero carousel layout._

Attribute | Value
 |
Alignment | Vertically centered |
Leading/Trailing padding | 16dp |
Top/bottom padding | 8dp |
Padding between elements | 8dp |
Large item width | Dynamic |
Small item width | 40-56dp, dynamic |
Item corner radius | 28dp |

## Full-screen

The full-screen layout shows one edge-to-edge large item.

_footer: - Container - Large carousel item_
_altText: 2 elements of a full-screen carousel layout._

### Measurements

_footer: Full-screen carousels fill the window edge-to-edge_
_altText: Measurements of a full-screen carousel layout._

Attribute | Value |
Alignment | Centered |
Leading/Trailing padding | 0dp |
Top/bottom padding
 | 0dp |
Padding between elements
 | 16dp |

<!-- section: Guidelines -->

_footer: Carousel items adapt dynamically based on breakpoint_
_altText: Carousel items adapting dynamically to device size by shrinking and reducing in number._

## Usage

Carousels display a scrollable list of items. Carousel items emphasize visuals, but can also contain brief text that adapts to the item size.

There are four carousel layouts:

- Multi-browse
- Uncontained
- Hero
- Full-screen

All of these layouts can be centered, though center-aligned hero is the most common centered carousel.

Carousels can scroll in two ways:

- **Default**: Standard scrolling. Recommended for uncontained layouts.
- **Snap-scrolling**: Scrolled items snap to the carousel's layout. Recommended for multi-browse, hero, and full-screen layouts

_footer: A carousel can contain different sized items_
_altText: Contained carousel with a large, medium, and small item. Text is hidden on the small item._

Choose the best carousel layout for your product. Some layouts are more visual-focused, while others are more customizable.

Layout | Best used for |
[Multi-browse](/m3/pages/carousel/guidelines#d95cefa4-53df-45e2-bbb2-3aeeecbe9639) | Browsing many visual items at once (like photos), dynamic designs |
[Uncontained](/m3/pages/carousel/guidelines#96c5c157-fe5b-4ee3-a9b4-72bf8efab7e9) | Highly-customized or text-heavy carousels, stacked imaged and text, traditional carousel behavior |
[Hero](/m3/pages/carousel/guidelines#5991f961-79aa-4955-b86e-3e15432108e6) | Spotlighting very large visual items (like a movie or featured app) |
[Center-aligned hero](/m3/pages/carousel/guidelines#a9f8dcde-e5c5-464f-b488-d9ded9ae4a4a) | Centered, large visual items |
[Full-screen](/m3/pages/carousel/guidelines#ae0f1566-a956-4c4b-b153-d50ee20c32e7) | Vertically-scrolling video or image feeds, immersive experiences |

Carousel items must be fully visible on-screen (except for the uncontained layout). When scrolled, items automatically change size and snap into place to maintain the same layout.

_footer: Set the large carousel item size to ensure the images and text are easy to read and recognize_
_altText: Multi-browse carousel with all images and text easily legible._

_footer: Avoid setting carousel items so small that the image isn't recognizable_
_altText: Multi-browse carousel with a very thin small item, making the image unrecognizable._

### Accessibility requirements on scrolling pages

On vertically-scrolling pages, carousels require an accessible way to view all the items without horizontally scrolling. (This requirement doesn't apply to full-screen carousels.)

Material recommends adding a **Show all** button below the carousel, which opens a dedicated vertically-scrolling page of all carousel items.

If the carousel has a header, you can use an arrow icon button instead. 

View the [accessibility tab](/m3/pages/carousel/accessibility) for more details and alternate solutions.

_footer: Make sure users can scroll vertically through all carousel items_
_altText: Carousel on mobile has a "show all" button that opens a page with all carousel items._

### Multi-browse

The multi-browse layout is best for browsing many items at once, like photos or event feeds. Snap-scrolling is recommended to ensure items are recognizable and consistently sized.

On larger screens, more large and medium items are visible in this layout.

Avoid using this layout if the carousel items need lots of text or have complicated imagery.

_footer: A multi-browse layout has different sized items within the carousel_
_altText: Swiping a multi-browse carousel with snap-scrolling. Items adjust size to fit the layout._

At compact breakpoints, only show up to three carousel items if they have text.

If you need to show more than three items, make sure the images and content are easy to understand and recognize.

_footer: At compact breakpoints, only show more than three items if the items are easy to understand and recognize_
_altText: Carousel on a phone. 2 large, 1 medium, and 1 small item are fully visible but thin. The items don't have text._

### Uncontained

The uncontained layout is most similar to a traditional carousel, where items are a single size and flow past the edge of the screen.

Both default scrolling and snap-scrolling work well with this layout.

Since items don't change size, this layout can be customized to show more text or other UI above or below each item without the text being masked or cropped.

_footer: Carousel items are all the same size in an uncontained layout_
_altText: Swiping an uncontained carousel with default scrolling. Items scroll to the edge and can stop anywhere._

### Uncontained multi-aspect ratio

The uncontained multi-aspect ratio carousel has the same layout as the uncontained carousel but contains items of various sizes.

Item widths can range anywhere between 9:16 for min width size to 16:9 for max width.

Only use this carousel layout if the items have various widths.

_footer: Carousel items are of various sizes in an uncontained multi-aspect ratio layout_
_altText: Swiping an uncontained carousel with default scrolling. Items scroll to the edge and can stop anywhere._

### Hero

The hero layout is best for spotlighting content that needs more attention, like movie, shows, or other media thumbnails. It highlights one large image to focus on, while providing a sneak peek of what’s next. 

On larger screens, more large items are visible.

Use snap-scrolling so users can easily cycle through items one at a time.

_footer: A hero carousel at a compact breakpoint should show one large item and one small item_
_altText: Swiping a hero carousel with snap-scrolling. Items adjust size to fit the layout._

### Center-aligned hero

When the hero layout is center-aligned, it adds an additional previewed item on the leading edge, making the large carousel item centered.

_footer: A centered hero carousel has two small carousel items, with a large item centered_
_altText: Swiping a center-aligned hero carousel with snap-scrolling. Items adjust size to fit the layout._

### Full-screen

The full-screen layout is best used for immersive experiences like video articles, featured headlines, or items that are visually rich. It can contain text and other UI elements on top of the image.

This layout works best with content that is taller than it is wide, and scrolls vertically. It only works in portrait orientation in compact and medium breakpoints. Don't use this layout in landscape orientation.

Use snap-scrolling for full-screen layouts. Don't use default scrolling.

_footer: Full-screen carousels fill the entire content area of the screen_
_altText: Vertically swiping a full-screen carousel with snap-scrolling. Items fit edge-to-edge._

## Anatomy

_footer: Multi-browse carousel (left) and hero carousel (right):  - Container - Large carousel item - Medium carousel item - Small carousel item_
_altText: 4 elements of a carousel._

### Container

The carousel container holds all carousel items. The number of carousel items visible in the container can change based on the carousel layout and breakpoint.

_footer: The carousel container is a rectangle. It can be used in many ways and stretched to any size._
_altText: An empty rectangle representing a carousel container._

### Carousel items

Carousel items hold content. A carousel item has no fixed width; it changes width depending on the breakpoint or its position in the carousel's layout. There are three dynamic widths an item can be: **large**, **medium**, and **small**.

_footer: - Large carousel item - Medium carousel item - Small carousel item_
_altText: 3 sizes of carousel items._

Large items have a max width that can be adjusted. This changes how all other large, medium, and small carousel items fit on screen. Large items must remain big enough to be easy to understand and recognize.

Medium items adjust width dynamically to the carousel size and available space. 

Small items have a width range of 40–56dp.

_footer: - Large item - Small item_
_altText: 2 sizes of carousel items for hero layouts._

When the large item's max width is narrow enough, more items can be shown on screen at once. At compact breakpoints, this is only recommended for carousels with simple imagery.

_footer: - Large item - Medium item - Small item_
_altText: 3 sizes of carousel items for multi-browse layouts. 2 large items are visible._

### Item text (optional)

Carousel items are primarily visual. Item text is optional and should be brief. 

If your carousel items require a lot of text, consider using the **uncontained layout**, which can show more information, or use a series of cards instead.

_footer: Avoid exceeding two lines of text in carousel items at compact breakpoints unless the background is simple, like a single color_
_altText: Contained carousel items with 5 lines of content: a title, a description, and a label._

Content within a carousel item can adapt dynamically based on the container and breakpoint. 

Text should always be understandable at each size. Consider adapting the text to use brief labels on smaller carousel items.

_footer: - Large carousel item with the full title and label text - Medium carousel item hiding the title text - Small carousel item abbreviating the label text_
_altText: A carousel item at 3 different sizes to show  how text changes at each size._

## Adaptive design

As the carousel container size increases, so do the number of carousel items visible at a time.

At compact breakpoints, carousels can comfortably show up to three carousel items at once.

At larger breakpoints, more carousel items are added and scale in size.

Full-screen carousels only ever show one item at once.

_footer: Carousels can show more items at once on larger screens_
_altText: 8 carousel items visible at once on a tablet in landscape orientation._

## Behavior

### Scrolling

Carousel items have a parallax effect when they're scrolled.

The **default** scrolling behavior doesn't snap items to a layout grid. They can stop anywhere in the container. Only use this for the uncontained layout.

The **snap-scrolling** behavior aligns carousel items to the layout grid after they're scrolled. Items snap to the grid when released. Use this for multi-browse, hero, and full-screen layouts.

_footer: Carousel items with snap-scrolling maintain the same layout when released_
_altText: Multi-browse carousel with snap-scrolling. Items slot into the layout once scrolled._

In full-screen layouts, make sure the carousel items snap to the edges of the carousel container. Avoid letting them scroll freely or stop halfway.

Full-screen layouts must use snap-scrolling.

_footer: Avoid scrolling freely on full-screen carousels_
_altText: Full-screen carousel with items stopping halfway off screen once scrolled._

<!-- section: Accessibility -->

## Use cases

Users should be able to do the following with assistive technology:

- Navigate to the carousel container
- Navigate between different carousel items
- Activate a carousel item
- Skip over the carousel items

## Requirements on scrolling pages

On vertically-scrolling pages, carousels require an accessible way to view all the items without horizontally scrolling. (This requirement doesn't apply to full-screen carousels.)

Material recommends adding a **Show all** button below the carousel, which opens a dedicated vertically-scrolling page of all carousel items.

_footer: Carousels without headers should use a **Show all**button to view all carousel items_
_altText: Carousel on mobile has a "show all" button that opens a page with all carousel items._

_footer: The **Show all** button should have a padding of 4dp_
_altText: Measurements of a "show all" button added below a carousel._

If the carousel has a header, you can use an arrow icon button instead. Place the arrow icon directly next to the header or in the same row.

Make sure the header is also displayed on the page of all carousel items.

_footer: Carousels with headers should use an arrow to view all carousel items_
_altText: Carousels in a list on mobile with headers have an arrow icon that opens a page with all carousel items._

_footer: Headers should align with the leading edge, and the arrow icon should have a size of 48dp_
_altText: Measurements of an arrow icon button added next to a carousel header._

Avoid customizing the accessibility solution when possible. However, if your product needs an alternative solution, consider adding a **Show all** button in nearby navigation, or add alternative control buttons close to the carousel.

Avoid adding UI elements, like arrows or other icons, within or beside the carousel.

_footer: Avoid adding buttons into the carousel container or beside it. Place any buttons above or below the carousel._
_altText: Arrow icons on the left and right of the carousel, reducing container width._

_footer: Don't cover the carousel with buttons or other UI_
_altText: Arrow icons floating on top of the carousel edge, concealing items._

## Interaction & style

### Touch

Tapping on a carousel item changes the shape slightly, and creates a touch ripple for interaction feedback.

_footer: Touch: Tap_
_altText: Carousel providing a ripple feedback when being tapped._

### Cursor

The hover state provides a visual cue that the carousel item is interactive.

When the carousel item is clicked (in both active and inactive states), a ripple appears for interaction feedback.

_footer: Cursor: Hover, click_
_altText: Carousel changing state when hovered._

### Initial focus

When navigating to a carousel using assistive technology, use **Tab** to place initial focus on the first carousel item. Then, use **Tab** or the arrow keys to navigate the carousel items.

Use the up and down arrow keys to leave the carousel and focus on the next element on the page, like the **Show all** button.

_footer: Set initial focus on the first carousel item, and use arrows to navigate items_
_altText: Diagram of how to navigate a carousel using assistive technology._

_footer: Avoid focusing on the carousel container_
_altText: Diagram of how not to navigate a carousel using assistive technology._

## Keyboard navigation

Keys | Actions |
**Tab**or **Arrows** | Moves to the previous or next carousel item
 |
**Space** or **Enter** | Activates the focused carousel item |

## Labeling elements

The carousel container has the **container** role.

_footer: The carousel container is labelled appropriately and has the **container** role_
_altText: Accessibility labels of a carousel._

Each carousel may have a different number of items, so the label reads out the total amount of items and the current item in focus.

_footer: The carousel item label indicates the current item in focus and the total number of items_
_altText: Accessibility labels of a carousel item._

## Reduced motion

When reduced motion settings are turned on, the parallax effect should be removed and carousel items should no longer expand as they come into view. All items are the same size.

Make sure carousels with reduced motion reach the edges of the window to avoid clipping visuals.

_footer: - Default carousel for multi-scroll - Carousel with reduced motion settings turned on_
_altText: Comparison of a multi-browse carousel with the reduced motion setting off and on._

For hero carousels with reduced motion, the small carousel item is only partially shown on screen.

_footer: - Default carousel for single-scroll - Carousel with reduced motion settings turned on_
_altText: Comparison of a hero carousel with the reduced motion setting off and on._

---

<!-- Source: m3.material.io · components_lists · updated 2026-08-06T17:09:16.197Z · CC-BY 4.0 (Google) -->

## Lists



<!-- section: Overview -->

-
Use lists to help people find a specific item and act on it

-
Order list items in logical ways, like alphabetical or numerical

-
Keep items short and easy to scan

-
Show icons, text, and actions in a consistent format

-
Choose between standard and segmented styles

_footer: A list item's label text, supporting text, image, and trailing icon can be customized to create a variety of lists_
_altText: 1 list contains 3 items, each with a label text, supporting text, and trailing text. A music app shows list items with leading images._

## Availability & resources

## M3 Expressive update

Lists have a new segmented visual style, improved selection treatment, and support for slots. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

**December 2025** 

Variants:

-
Added **expressive** list

Recommended for new designs

-
List (baseline) is still available

New visual styles:

-
Standard or segmented

-
Highlighted selection states

-
Flexible slots

Supported platforms:

-
[Android Views (MDC-Android)](https://github.com/material-components/material-components-android/blob/master/docs/components/List.md#m3-expressive)

-
[Jetpack Compose](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#ListItem%28kotlin.Function0,androidx.compose.ui.Modifier,kotlin.Function0,kotlin.Function0,kotlin.Function0,kotlin.Function0,androidx.compose.material3.ListItemColors,androidx.compose.ui.unit.Dp,androidx.compose.ui.unit.Dp%29)

_footer: Expressive lists feature improved selection states_
_altText: 2 party planning lists with 2 completed list items each. In 1 list, the selected items are highlighted._

## Differences from M2 to M3 baseline

-
**Color:** New color mappings and compatibility with dynamic color

-
**Layout:** Padding and spacing rules are updated to be more consistent

-
**Height:** The tallest element within a list item determines the list item’s height - either 56dp, 72dp, or 88dp

-
**Alignment:**

In most cases, elements in a list item are middle-aligned

-
If a list is 88dp or larger, or contains three or more lines of text, elements are top-aligned

_footer: M2: Non-standard heights and alignments_
_altText: 3 variants of lists in M2._

_footer: M3 (baseline): Standardized heights and alignments_
_altText: 3 variants of lists in M3 baseline._

<!-- section: Specs -->

## Variants

### Expressive lists

Use the expressive list variant for more flexible styling, highlighted selection states, and customizable slots.

_footer: An **expressive list** has a segmented style and round corners_
_altText: 2 expressive lists: a photos list on a tablet, and a song list on mobile._

### Baseline lists

Baseline lists are still available to use, but don’t have the latest visual style, selection treatment, and slot functionality.

On web, expressive lists are built on top of baseline lists.

[See baseline list specs](/m3/pages/lists/specs#94cf7f4d-fe29-4fab-9aae-a99e9b754329)

_footer: **Baseline list items** have square corners and standard colors_
_altText: 3 baseline list items with square corners._

**Variants**
 |
**M3**
 |
**M3 Expressive**
 |

Lists (expressive)
 |
--
 |
Available
 |

Lists (baseline)
 |
Available
 |
Not recommended.  

Use expressive lists instead.
 |

## Configurations

### Styles

The standard and segmented styles are a visual choice, and don’t affect a list’s behavior.

_footer: - Standard  - Segmented_
_altText: A standard list and segmented list in dark mode._

### List selection

A list can have only one selection mode at a time. For example, a single-action list can change to a multi-select list, but can’t be both at once.

_footer: In a **single-action list**, each item is a single tappable area_
_altText: A single-action list with 4 items and no additional actions._

_footer: **Multi-action list** items include a primary action, and one or more secondary actions_
_altText: A list with 4 items. Each item has 2 trailing icons for additional actions._

_footer: A **single-select list**_
_altText: A list with 1 item selected._

_footer: A **multi-select list**_
_altText: A list with 2 items selected._

### List interactions

Lists can:

-
[Expand and collapse](/m3/pages/lists/guidelines#90a236ee-b587-4361-8911-34006f25a6f1)

-
[Swipe to reveal](/m3/pages/lists/guidelines#01204f7d-ce32-4739-aece-e95db24858c9)*

[More on list interaction accessibility](/m3/pages/lists/accessibility#a6f937f5-3e1f-4db4-ba35-ac6dd9fef140)

_footer: A list can **expand** to include multiple items_
_altText: 1 list item expands into a list with 6 items, then collapses._

_footer: A list item can be **swiped** to reveal more actions_
_altText: A list item is swiped, and reveals 3 more actions._

**Category**
 |
**Configuration**
 |
**M3**
 |
**M3 Expressive**
 |

Styles
 |
Standard
 |
Available
 |
Available
 |

Segmented
 |
--
 |
Available
 |

Selection modes
 |
Single-action, multi-action,

single-select, multi-select
 |
Available
 |
Available
 |

Interactions
 |
Expand, swipe*
 |
Available
 |
Available
 |

* Swipe-to-reveal interactions are only available on Android Views

## Tokens & specs

Use the table's menu to select a token set. The **common** set combines baseline tokens with new expressive shapes and sizes. The **expand** set has tokens for the expand interaction. [Learn about design tokens](/m3/pages/design-tokens/overview)

## Anatomy

_footer: Container and label text are required. All other elements are optional:  - Container  - Overline  - Label text  - Trailing text  - Supporting text  - Trailing icon  - Divider  - Leading avatar  - Leading icon  - Leading media - image or video_
_altText: Diagram with 10 elements that can be included in lists._

### Flexibility & slots

The [M3 Design Kit](https://www.figma.com/community/file/1035203688168086460) includes lists with custom slots for designing flexible item layouts. Think of a custom list as a container with three different slots: leading, content, and trailing. Each slot can hold a different element.

#### **Slot accessibility**

Slots are not accessible by default. Consider the following:

-
Elements must follow the rules, structure, and interaction patterns for lists

-
Use standard list item padding

-
Target size must be at least 48x48dp

-
Don't add interactive elements that make the list item difficult to navigate, especially for people using screen readers

[More on required accessibility guidelines](/m3/pages/lists/accessibility#538f23f7-689c-4516-bfc8-5f6933a43f5e)

_footer: Reserve the use of slots for use cases that maintain the list’s accessibility and functionality  - Leading slot  - Content slot  - Trailing slot_
_altText: A diagram with leading, content, and trailing slots._

warningCaution:Slots require custom code implementation that you must create and maintain

The **leading** and **trailing** slot positions must be a smaller width than the **content** section.

1. **Leading slots** can contain:

-
Visual elements: Avatar, icon, image, or video thumbnail

-
Selection controls: Checkbox, radio button, or switch

-
Customizations: Badge or larger image

2. **Content slots** must be the largest-width slot and can contain:

-
Default content: Label text, supporting text

-
Optional add-ons: Badge, icon, in-line label, or more text elements

-
Avoid long lines of text to preserve readability

3. **Trailing slots** can contain:

-
Action elements or text: Icon, icon button, or trailing text

-
Selection controls: Checkbox, radio button, or switch

_footer: The content slot must be the largest section, placed in the middle of the list item_
_altText: Slot diagram showing slot placement in the middle of the list._

#### Selection lists

For selection lists, use only one selection interaction per list item.

_footer: Use only one selection interaction per list item_
_altText: A selected list item with a checkmark in the leading slot._

_footer: Don't use multiple selection interactions in one item_
_altText: A selected list item with both a checkmark in the leading slot and a bookmark in the trailing slot._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: List color roles used for light and dark themes:  - Surface  - On surface variant  - On surface  - On surface variant  - On surface variant  - On surface variant  - Outline variant  - Primary container  - On primary container  - On surface variant_
_altText: 10 list element color roles in light mode and dark mode._

## States

States are visual representations used to communicate the status of a component or an interactive element. [Learn more about interaction states](/google-material-3/pages/interaction-states/overview)[More on list focus](/m3/pages/lists/accessibility#f7e067e1-722f-40c5-a95a-63929869bf3e)

### Default list items

_footer: - Enabled  - Disabled  - Hovered  - Focused  - Pressed  - Dragged_
_altText: 6 default list states in light and dark mode._

### Selected list items

_footer: - Enabled  - Disabled  - Hovered  - Focused  - Pressed  - Dragged_
_altText: 6 selected list states in light and dark mode._

## Measurements

_footer: List item alignment, padding, and size measurements. The icon button height is dynamic, and automatically adjusts to fill the list item height._
_altText: Size and padding measurements for list items._

### Shape morphing

When a list item is selected, the corner shape changes to highlight the active item:

-
Unselected corner radius: 4dp inner, 16dp outer

-
Selected corner radius: 16dp

_footer: Unselected list items have a 4dp inner corner radius, and 16dp outer corner radius_
_altText: A 3-item list. The middle item is unselected, with a 4dp corner radius._

_footer: Selected list items have a 16dp corner radius all around_
_altText: A 3-item list. The middle item is selected, with a 16dp corner radius._

## List (baseline)

The baseline list variant is available and continues to work in existing products. However, the [expressive list](/m3/pages/lists/specs#ebf87f58-d5bf-4cb5-a856-d2bb104eec4d) variant is recommended for new designs.

### Tokens & specs

Baseline list tokens are in the **common** token set. Note: This set also includes several expressive tokens.

### Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: List color roles used for light and dark themes:  - Surface  - On surface  - On surface variant  - On surface variant  - On surface variant  - Outline variant  - Primary container  - On primary container  - On surface variant_
_altText: 9 baseline list element color roles in light and dark mode._

### States

States are visual representations used to communicate the status of a component or interactive element.

_footer: 1. Enabled  2. Disabled  3. Hovered  4. Focused  5. Pressed  6. Dragged_
_altText: 6 baseline list states in light and dark mode._

### Layout

#### One-line lists

_footer: Baseline one-line list alignment, padding, and size measurements_
_altText: Alignment, padding, and size specifications for baseline list items with 1 line of text._

_footer: Baseline list item measurements and padding_
_altText: Measurements for a 3-item list with 1 line each._

#### Two-line lists

_footer: Baseline two-line list alignment, padding, and size measurements_
_altText: Alignment, padding, and size specifications for baseline list items with 2 lines of text._

_footer: Baseline list item measurements and padding_
_altText: Measurements for a 3-item list with 2 lines each._

#### Three-line lists

_footer: Baseline three-line list alignment, padding, and size measurements_
_altText: Alignment, padding, and size specifications for baseline list items with 3 lines of text._

_footer: Baseline list item measurements and padding_
_altText: Measurements for a 3-item list with 3 lines each._

Attribute | Value |

Label alignment
 |
Center
 |

Label alignment when height is 88dp or taller
 |
Top
 |

Label left padding
 |
16dp
 |

Leading element alignment (vertical)
 |
Center
 |

Leading element alignment (vertical) when height is 88dp or taller
 |
Top
 |

Leading element left padding
 |
16dp
 |

Leading icon alignment (vertical)
 |
Top
 |

Leading icon top padding
 |
8dp
 |

Leading icon top padding when height is 88dp or taller
 |
12dp
 |

Trailing element alignment (vertical)
 |
Center
 |

Trailing element alignment (vertical) when height is 88dp or taller
 |
Top
 |

Trailing element left padding
 |
16dp
 |

Trailing element right padding
 |
24dp
 |

Padding above/below divider
 |
0dp
 |

Targets
 |
48dp
 |

Divider full-width
 |
100%
 |

Divider inset left padding
 |
16dp
 |

Divider inset right padding
 |
24dp
 |

### Configurations

#### Leading avatar

_footer: - With leading avatar  - With leading avatar and trailing checkbox_
_altText: 1, 2, and 3-line list items with and without a leading avatar and trailing checkbox, in dark mode._

#### Leading image or thumbnail

_footer: - With leading image  - With leading image and trailing checkbox_
_altText: 1, 2, and 3-line list items with and without a leading image and trailing checkbox, in dark mode._

#### Leading video

_footer: - With leading video  - With leading video and trailing checkbox_
_altText: 1, 2, and 3-line list items with and without a leading video and trailing checkbox, in dark mode._

#### Leading icon

_footer: - With leading icon  - With leading icon and trailing checkbox_
_altText: 1, 2, and 3-line list items with and without a leading icon and trailing checkbox, in dark mode._

#### Text-only

_footer: - With text only  - With text and trailing checkbox_
_altText: 1, 2, and 3-line text only list items with and without a trailing checkbox, in dark mode._

#### Leading checkbox

_footer: - With leading checkbox  - With leading checkbox and trailing text_
_altText: 1, 2, and 3-line list items with and without a leading checkbox and trailing text, in dark mode._

#### Leading radio button

_footer: - With leading radio button  - With leading radio button and trailing text_
_altText: 1, 2, and 3-line list items with and without a leading radio button and trailing text, in dark mode._

#### Trailing switch

_footer: - With trailing switch  - With leading icon and trailing switch_
_altText: 1, 2, and 3-line list items with and without a leading icon and trailing switch, in dark mode._

<!-- section: Guidelines -->

_footer: Lists can include a range of layout combinations:  - Leading images, videos, icons, or avatars  - Trailing text, icons, or icon buttons_
_altText: 3 list items show different layout options, with varying sizes of elements in the leading slot._

## Usage

Lists are vertical groups of text, icons, images, and other elements, optimized for reading comprehension.

List items can contain multiple actions at once, like selection, icon buttons, overflow menus, and more.

_footer: A clear visual hierarchy makes lists easy to scan and read_
_altText: 3 list items with avatars using different expressive shapes._

Use lists for communicating or selecting discrete items, such as choosing from a set of colors.

_footer: Lists are an organized way to add imagery and supporting elements to selection. In this color selection example, the list contains color swatches, color names, and a checkbox action._
_altText: A list of colors with Periwinkle selected._

A list should be easy to scan. Any element can be used to anchor and align list item content.

Place supporting visuals and primary text in the same position in each list item.

Don’t vary the position of elements within a list.

_footer: - Sample list - Content placement in a row - Supporting visuals are aligned for easy scanning - Primary text is aligned for easy scanning_
_altText: 4 versions of the same list highlighting avatar and text alignment._

List items can adapt to different lengths of text:

**Label text only**A list item can contain a single line of label text. If the text doesn’t fit on one line, it can wrap or be truncated.

**Label text with supporting text**A list item can include supporting text below the label text. Both the label and supporting text can wrap or be truncated.

_footer: Three examples of list item sizes:  - Label text only  - Label text with supporting text on one line  - Label text with supporting text that wraps to two lines_
_altText: 3 lists show items with label text only, label text with 1-line of supporting text, and label text with 2-lines of supporting text._

## Anatomy

_footer: Container and label text are required. All other elements are optional:  - Container  - Label text  - Supporting text  - Trailing text  - Trailing icon  - Trailing selection control - checkbox, radio button, switch  - Leading avatar container  - Leading avatar text  - Leading icon  - Leading media - image or video_
_altText: List diagram with 10 elements._

### Container

List containers hold all list items and their elements. List item size is determined by the tallest element within the list item. [See layout measurements](/m3/pages/lists/specs#1824b94d-7d17-4a29-889f-d277037a1313)  

When a list item features an image, consider customizing the container color to use a content-based color scheme. This should be applied to either the enabled state or for an interaction.

_footer: A list item can include a leading image and a vibrant color_
_altText: A song list with a leading images. When selected, a list item’s container matches the image’s color scheme._

### Label & supporting text

Keep label text brief.   

To ensure list items are scannable:

-
Limit supporting text to one to three lines

-
Truncate supporting text, depending on screen size

[See adaptive guidance](/m3/pages/lists/guidelines#561cc637-aa43-4055-be1e-0716faeef7af)

_footer: Limit supporting text to one to three lines_
_altText: A list item with a leading image, concise label text “Art events”, and 2 lines of truncated supporting text._

### Icons

**Leading icon**
A leading icon should provide a quick visual cue that relates to the item's label text, helping people scan the list.

**Trailing icon**
A trailing icon is often used to communicate status or indicate an action, like **Show more**.

_footer: - Leading icons should relate to the label text  - Trailing icons can communicate an action_
_altText: Leading icons should relate to the label text A list of items with leading and trailing icons on a mobile device._

### Leading media

List items can contain a leading avatar, image, or video. Anchor visuals to the leading edge of the list to improve scannability.

Leading video thumbnails can open a video player or even play within the list.

_footer: Place supporting visuals, like thumbnails, at the leading edge of a row to improve scannability_
_altText: A list of plants with images at leading edge._

_footer: Avoid placing visuals in the center of a row because it makes the list difficult to scan_
_altText: A list of plants with an image in the middle of the row makes it difficult to align the name and price._

#### Avatars

List items can include images in circular or expressive shapes to represent a person or entity.

Use square or rectangular images for other content, such as products or videos.

_footer: Use an expressive, circular avatar to represent a person or entity_
_altText: List of contacts with avatars with a circular, expressive crop to indicate a person._

#### Primary & secondary actions

Use spacing to draw attention to the most important aspect of the list item, usually the primary action area or key content.

_footer: The primary action takes up more space:  1. Primary action area  2. Secondary action area_
_altText: A folder icon in the primary action area takes up the full height of the list item._

_footer: Align content by importance:  1. More distinguishing content  2. Less distinguishing content_
_altText: A list item has an avatar in the more distinguishing content position on the left, and “15 min” trailing text on the right._

### Trailing text

Trailing text can provide additional meta-information about a list item, such as a price, count, or other details.

_footer: Use trailing text for supplemental details, like a price, count, or date_
_altText: The date “Nov 17” as trailing text in a concert ticket list item._

### Selection controls

Selection controls display list item actions. Position controls at the leading or trailing end of a list item:

-
Use checkboxes to select multiple items

-
Use switches to toggle settings on or off

-
Use radio buttons to select a single item

_footer: List items with:   - Checkboxes  - Switches   - Radio buttons_
_altText: 3 lists with different selection controls._

### Gaps & dividers

Gaps or dividers can separate lists into items and groups:

-
Use **gaps** for contained lists. Gaps leverage expressive shape and containment tactics.

-
Limit **dividers** to uncontained or complex lists, only when a stronger visual separation is necessary.

_footer: Use **segmented gaps** and filled list items to define a list group_
_altText: Filled list items in an inbox separated by gaps._

_footer: Limit the use of **dividers** to uncontained lists_
_altText: An uncontained list with city names separated by dividers._

## Adaptive design

### Line length

In fluid layouts, avoid excessively long lines of text when expanding containers and text-heavy components. This often means changing margins and typography properties as the container scales.

_footer: Adjust margins to create a more comfortable line length for reading_
_altText: 4 list items with 2-line supporting text have adjusted margins to preserve readability._

Adapt the width of the list container based on a line’s length, or by switching to a multi-column layout.

_footer: A multi-column layout can help break up content when needed_
_altText: List items in a 2-column layout, with each item showing text preview._

The ideal line length for text is typically between 40 to 60 characters, but large-screen devices can accommodate up to 120 characters per line. If a line of text is close to 120 characters in length, consider increasing the line height to improve readability .

_footer: Don’t scale components without adjusting other affected areas of the screen, such as text length. This can result in line lengths that make reading difficult._
_altText: List items with elongated line length._

A list with a compact breakpoint can become part of a two-column layout at an expanded breakpoint, adjusting the amount of information shown in each list item.

_footer: Reduce the amount of information shown at compact breakpoints_
_altText: Animation of a list on mobile and the same list adapted into a 2-column layout on desktop._

### Adapt list elements & layout

Lists can change their layout to adapt to different breakpoints. This affects the size and placement of content.

For example, a list at a compact breakpoint can adjust margins, spacing, or density to better fit an expanded window.

_footer: On larger screens, lists can show more content, like supporting text and larger imagery_
_altText: Photo list on mobile expands to allow larger images and longer descriptions on a tablet._

### Swap components

Lists are just a compact composition of images, text, and actions. Other components, like cards and carousels, use the same elements but take up more space.   

At larger breakpoints, consider swapping a list to a component with a similar purpose to take advantage of available space.

_footer: Information displayed in list items on mobile can change to cards on tablet and desktop_
_altText: A mobile photo list changes into cards in a larger window._

### Compact breakpoints

Lists should extend edge-to-edge in compact windows. Selecting a list item should open a page with the details.

_footer: On small screens, people can navigate between lists and full-screen detailed views_
_altText: When opened, a mobile photo list item expands to fill the width of the screen._

### Medium & expanded breakpoints

Medium and expanded breakpoints, such as tablet and desktop screens, can display primary and secondary content in the same view.

For example, a list and the detailed information can appear side-by-side.

_footer: On larger screens, a list-detail view can be more appropriate_
_altText: A larger screen displays list items and a detailed expansion of one item on the same screen._

At a larger breakpoint, a list may transform into a carousel.

_footer: Lists can transform into carousels in expanded windows_
_altText: A photo list with thumbnails in a compact window expands into a carousel with large images in an expanded window._

Lists can also show more or less content as they scale up and down in size.

For example, a list item can reveal more content when the component expands.

_footer: List items reveal supporting text at expanded breakpoints_
_altText: A list expands from a compact to a medium window. The expanded items show supporting text._

## Behavior

### List selection modes

The selected state applies to the entire list item. For example, when an item with a checkbox is selected, both the list item and the checkbox show a selected state.

#### Single-select

Lists can feature a single-selection component such as a radio button.

Single-select list items:

-
Don’t support multi-actions

-
Can’t have secondary nested actions

-
Shouldn’t use checkboxes

_footer: Use radio buttons to allow a single selection in a list_
_altText: A 3-item list with radio buttons, with 1 item selected._

#### Multi-select

Multi-select lists allow for multiple list items to be toggled on.

Multi-select list items:

-
Pair well with checkboxes and switches

-
Can’t have secondary nested actions

-
Shouldn’t use radio buttons

_footer: Use checkboxes or switches for multi-select lists_
_altText: A 3-item list with checkboxes and 2 items selected._

#### Single-action

In a single-action list, the entire list item performs one action, such as navigating to a new page.

Single-action list items:

-
Can’t have secondary nested actions

-
Can’t be toggled into a persistent selected state

_footer: Use a single-action list for a primary action, like navigation_
_altText: A 3-item list where each item is a single tappable area._

#### Multi-action

Multi-action lists can support multiple nested actions within a list item.

The primary action should take up the majority of the space in the leading and content positions.

Place supplementary actions, like a bookmark or menu, in the trailing position.  

[More on multi-action accessibility](/m3/pages/lists/accessibility#b69b89a9-7ca0-4249-b25b-2d0c85a41dc0)

_footer: Place supplementary actions in the trailing position of a list item_
_altText: A 3-item song list where each item has 2 trailing icons: a bookmark and overflow menu._

#### Non-interactive

Non-interactive lists can organize information in a scannable way. They don’t perform any actions and can’t be selected.

_footer: Use non-interactive lists to make information easy to scan_
_altText: A 3-item non-interactive list showing a historic timeline of space travel._

### List interactions

#### Expand & collapse

List items containing other list items can expand and collapse in a folder-like manner, to reveal or hide content. 

Tapping a list item expands it vertically across the entire screen using a container transform transition pattern.

_footer: To expand a list item, display a parent-child transition_
_altText: On a to do list, an item expands, revealing nested child items._

#### Swipe

On Android, list items can reveal buttons on swipe. Use a mix of button styles for visual interest and hierarchy.  

The primary action must be the final end-aligned option. A full swipe triggers this action, clearing the list item and all other actions off-screen. 

Swipeable list items should include alternative ways to access hidden actions, such as a more icon.

[More on swipe accessibility](/m3/pages/lists/accessibility#32f5115c-b15e-4af6-8c1a-4807bee2bf7a)

_footer: When a list item is swiped, it can be archived or reveal more actions_
_altText: List of recipes with “Fresh baked breads” swiped to reveal a archive icon._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology:

-
Navigate to a list item 

-
Select a list item

## Indicate selection with more than color

To make selected items clear for everyone, don't rely on color as the only visual cue.   

Use an additional indicator that an item is selected such as:

-
Radio buttons or checkboxes

-
Leading or trailing icons

-
A visual style not related to color, like underlined text

_footer: Use two visual cues to show a list item is selected, like a leading checkmark and filled color_
_altText: A selected list item with a colored background, and a check as the leading icon._

## Interaction & style

### Touch

When a person taps on a list item, a touch ripple appears, indicating interaction feedback.

_footer: A ripple appears when a person taps on a list item to select it_
_altText: A 3-item list shows a touch ripple animation as the second item is tapped and selected._

### Cursor

When hovered, the hover state provides a visual cue that a list item is interactive.

_footer: Cursor: Hover_
_altText: A list with the second item visually altered while hovered over, with a cursor and darker fill._

_footer: Cursor: Selected_
_altText: Selected list item with cursor, colored fill, and checked box._

### Keyboard & switch

When a person tabs to a single-action list, a focus indicator appears, providing a visual cue that the first list item is now focused and action can be taken.

When a person interacts with the focused list item via **Space** or **Enter**, the action is performed.

_footer: **Tab** key navigates to the list. **Space** or **Enter** keys activate items._
_altText: A focus indicator appears on the first item of a 3-item list, which is then selected._

### Swipe

List items that can be swiped should include alternative ways to access hidden actions, such as a **more** icon.   

Swipe alternatives can be:

-
Single tap

-
Double tap

-
Long press

-
Other single-point interactions

_footer: List items can reveal more actions from swiping or using an accessible secondary action such as a double tap_
_altText: A list item has a “more” button selected to reveal additional actions._

## Focus

### Single-action lists

The first element in a list should always receive focus, unless the list has a selected element. In that case, focus should go to the selected list item instead.

After an element is focused, a person should be able to navigate within the list using arrow keys.

_footer: **Tab**key focuses on the first item or the selected item_
_altText: The first list item is automatically focused._

_footer: **Arrow**keys navigate up and down through list items_
_altText: A second list item focused using an arrow key._

All list items must be able to be activated using the **Space** or **Enter** key.  

[More on single-action lists](/m3/pages/lists/guidelines#3e45f939-457a-44a8-8551-a2354c521d26)

_footer: **Space** or **Enter** keys activate an element in a list_
_altText: List item with focus indicator and filled checkbox, selected using the Space or Enter key._

### Multi-action lists

Multi-action list items contain a primary action and at least one supplementary action.  

The list item as a whole isn't selectable; only the individual actions are.

 A person should be able to use a keyboard to:

-
**Tab** to the list item, which focuses the first element

-
Move between between all focusable elements in the list using the **Up**, **Down**, **Left**, and **Right** arrow keys

-
Activate a focused element using **Space** or **Enter**   

[More on multi-action lists](/m3/pages/lists/guidelines#db85439b-0e67-43b0-a2dc-61395738af64)

_footer: **Tab** brings the focus to the first action_
_altText: The first element in a multi-action list is focused automatically._

_footer: **Down** and **Right** arrow keys move focus to the next action of the list item, or to the first action in the next item_
_altText: The list action, a bookmark, is focused using the Down or Right arrow._

_footer: **Up** and **Left** arrow keys move focus to the previous action of the list item_
_altText: A trailing bookmark icon is focused in the second list item._

_footer: If the focus is on a list item’s first action, the **Up** and **Left** arrows move focus back to the last action of the previous item_
_altText: Label text and supporting text of the second list item is in focus using the Up or Left arrow._

_footer: The **Space** or **Enter** key activates a selected action in a list_
_altText: The Space or Enter key activates an overflow menu on a list item._

## Keyboard navigation

**Keys**
 |
**Actions**
 |

**Tab**
 |
To move focus to the first list item, last list item, or outside of the list component
 |

Down and right arrow keys
 |
Moves to the next element in the list; if the focused element is the last in the list, it wraps back to the top of the list
 |

Up and left arrow keys
 |
Moves to the previous element in the list; if the focused element is the first in the list, it wraps back to the bottom of the list
 |

**Space** or **Enter**
 |
To select a list item not yet selected
 |

## Labeling elements

Accessibility labels are used with assistive devices like screen readers.

The accessibility label for a list item is typically the same as the **label text** and **supporting text**.

Some labels, roles, and states are [dependent on platform](/m3/pages/lists/accessibility#09e32b7d-78a1-45c1-be12-4c6646cfe1d1).

_footer: A list item’s **label text** and **supporting text** is used for its accessibility label_
_altText: List item selected to show label of “Bread, sourdough or wheat”._

### Platform-specific labels

#### Single-select lists

**Trait**
 |
**Web**
 |
**Android Views (MDC-Android)**
 |
**Jetpack Compose**
 |

Aria label
 |
Container label: Should describe selection type

List item: Should match the visible label text 
 |
List item: Should match the visible label text 
 |
List item: Should match the visible label text 
 |

Role
 |
Container: List box  List item: Option
 |
List item: Radio button
 |
List item: Radio button
 |

State
 |
Selected or Not-selected
 |
Checked or Not-checked
 |
Checked or Not-checked
 |

#### Multi-select lists

**Trait**
 |
**Web**
 |
**Android Views (MDC-Android)**
 |
**Jetpack Compose**
 |

Aria label
 |
Container label: Should describe selection type

List item: Should match the visible label text 
 |
List item: Should match the visible label text
 |
List item: Should match the visible label text 
 |

Role
 |
Container: List box  List item: Option
 |
List item: Checkbox
 |
List item: Checkbox
 |

State
 |
Selected or Not-selected
 |
Checked or Not-checked
 |
Checked or Not-checked
 |

On web, a list container’s accessibility label describes the type of selection that can be made, and the role is **List box**.

_footer: On web, a list container’s role is **List box**_
_altText: A list container is selected, showing a label of “Select either bread, pita, or rice” and role of “List box.”_

On Jetpack Compose, the role applies to the list item as a whole.

If a list isn't selectable, the label text is read out without a role.

_footer: When selectable, the role **Checkbox**applies to the entire list item on Jetpack Compose_
_altText: A selected list item shows a label of “Bread, sourdough, or wheat” and role of “Checkbox.”_

On Android Views (MDC-Android), components contained within the list should be labeled according to that component’s specific guidelines:

-
[Checkbox](/m3/pages/checkbox/accessibility)

-
[Radio button](/m3/pages/radio-button/accessibility)

_footer: On Android Views (MDC-Android), the accessibility label and role are applied to the interactive component by default_
_altText: Checkbox of a selected list item shows label of “Bread, sourdough or wheat” and role of “Checkbox.”_

---

<!-- Source: m3.material.io · components_bottom-sheets · updated 2026-07-28T07:45:12.661Z · CC-BY 4.0 (Google) -->

## Bottom sheets



<!-- section: Overview -->

-
Use bottom sheets in compact and medium breakpoints

-
Two variants: standard and modal

-
Content should be additional or secondary (not the app’s main content)

-
Bottom sheets can be dismissed in order to interact with the main content

_footer: - Standard bottom sheet - Modal bottom sheet_
_altText: Side by side view of standard bottom sheet modal bottom sheet_

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Shape: Bottom sheets have a 28dp top corner radius
- Layout: New max-width of 640dp and an optional drag handle with an accessible 48dp hit target

_altText: Diagram of floating sheet set on screen background_

<!-- section: Specs -->

Modal bottom sheets are above a scrim while standard bottom sheets don't have a scrim. Besides this, both variants of bottom sheets have the same specs.

_footer: - Container - Drag handle (optional) - Scrim_
_altText: Diagram of container, drag handle, scrim_

## Tokens and specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Bottom sheet color roles used for both light and dark schemes:  - Scrim*  - On surface variant  - Surface container low  *On Android platforms, the scrim color and opacity is automatically handled by the system UI._
_altText: Two diagrams featuring color opposites of scrim, container, drag handle_

## Measurements

_footer: Bottom sheet padding and size measurements_
_altText: Bottom sheet on larger device with 56dp top and 56dp side margins_

Bottom sheets span the full window width up to 640dp. When the window width exceeds 640dp, bottom sheets adjust to have a top margin of 56dp and side margins of 56dp. 
Attribute | Value |

Drag handle alignment (horizontal)
 |
Center
 |

Drag handle padding top/bottom
 |
22dp
 |

Top margin
 |
72dp
 |
Top margin (window width > 640dp) | 56dp |

Start/end margin (window width > 640dp)
 |
56dp
 |

Width
 |
Full width, up to max-width 640dp
 |
Height | Variable |

<!-- section: Guidelines -->

_footer: - Standard bottom sheets - Modal bottom sheets_
_altText: Two variants of bottom sheets._

## Usage

Bottom sheets display supplementary content and actions on a mobile screen.

_footer: Bottom sheet containing contacts and applications_
_altText: Photo sharing bottom sheet with contact list, app icons, and action buttons._

Bottom sheets are a versatile component that can contain a wide variety of information and layouts, including menu items (in list or grid layouts), actions, and supplemental content.

_footer: Bottom sheet with menu items in a list_
_altText: Bottom sheet displaying 3 menu options._

## Anatomy

A container is the only required element of a bottom sheet. Bottom sheet layouts can vary widely to support the kinds of content they contain.

_footer: - Container - Drag handle (optional) - Scrim (modal only)_
_altText: 3 elements of a bottom sheet._

### Container

Bottom sheet containers hold all bottom sheet elements. Their size is determined by the space those elements occupy.

The container is the only required element of a bottom sheet. All other elements are optional.

_footer: Bottom sheets are flexible containers that adapt to their content and available space_
_altText: Empty bottom sheet container._

### List items (optional)

Lists are a continuous group of text or images. List items can include label text, icons, and text buttons, among other elements.

_footer: Bottom sheet containing a list with icons_
_altText: A bottom sheet displaying a list of actions for a song._

### Dividers (optional)

Dividers can be used to separate related content in bottom sheets.

_footer: Bottom sheet with a divider separating kinds of actions_
_altText: Bottom sheet with image action buttons and contact list separated by an inset divider._

### Media (optional)

**Thumbnail**
Bottom sheets can include thumbnails for an avatar or logo.

**Image**
Bottom sheets can include photos, illustrations, and other graphics, such as weather icons.

**Video**
Bottom sheets can include video.

_footer: Bottom sheets can contain thumbnails, images, and video_
_altText: A bottom sheet displaying various media formats, including thumbnails, images, and video._

## Standard bottom sheets

Standard bottom sheets co-exist with the screen’s main UI region and allow for simultaneously viewing and interacting with both regions, especially when the main UI region is frequently scrolled or panned.

Use a standard bottom sheet to display content that complements the screen’s primary content, such as an audio player in a music app.

_footer: The music player in this standard bottom sheet allows people to control their music while browsing albums_
_altText: Bottom sheet with music player controls visible while browsing albums._

At full-screen height, standard bottom sheets contain a collapse icon in an app bar to return to their initial position.

Standard bottom sheets can contain supplementary content that continues below the screen, such as location information over a map.

_footer: A bottom sheet can have preset positions from full-screen height to preview_

## Modal bottom sheets

Like dialogs, modal bottom sheets appear in front of app content, disabling all other app functionality when they appear, and remaining on screen until confirmed, dismissed, or a required action has been taken.

_footer: A modal bottom sheet must be interacted with or dismissed. Its blocking behavior makes it suitable for a menu, such as in this files app, to help people focus on their available choices._
_altText: A modal sheet with filter options to categorize files in the app._

Use a modal bottom sheet as an alternative to inline menus or simple dialogs on mobile, especially when offering a long list of action items, or when items require longer descriptions and icons.

Modal bottom sheets are used in mobile apps only.

_footer: Modal bottom sheets can be used instead of menus to present additional actions_
_altText: A modal bottom sheet displayed as an alternative to a traditional menu, presenting a list of actions._

### Visibility

To provide access to its top actions, the initial vertical position of modal bottom sheets is capped at 50% of the screen height.

Modal bottom sheets whose contents exceed 50% of the screen height can then be pulled across the full screen and scrolled internally to access their remaining items.

_footer: The initial vertical position of modal bottom sheets can't exceed 50% of the screen height_
_altText: A modal bottom sheet covering half of the screen, so both images and actions are accessible._

Modal bottom sheets appear when triggered by a user action, such as tapping a button or an overflow icon. They can be dismissed by:

- Tapping a menu item or action within the bottom sheet
- Tapping the scrim
- Swiping the sheet down
- Using a close affordance within the bottom sheet’s app bar, if available

Display a close affordance in a full-screen modal bottom sheet.

_footer: Tapping the scrim dismisses a modal bottom sheet_
_altText: A modal bottom sheet disappearing by tapping the scrim._

_footer: A modal bottom sheet can be dismissed by swiping the sheet down_
_altText: A modal bottom sheet disappearing by swiping the sheet down._

## Responsive layout

### Compact breakpoint

In compact breakpoints, like mobile devices, bottom sheets extend across the width of a screen and are elevated above the primary content.

_footer: Bottom sheets should extend to the width of the screen on mobile_
_altText: A bottom sheet extended to the width of a mobile screen._

### Medium and expanded breakpoints

For larger screens with medium and expanded breakpoints, bottom sheets have a default max-width to prevent undesired layouts and awkward spacing. However, this can be overridden if needed. For more complex tasks and flows, consider using a non-transient surface such as a floating sheet.

_footer: Bottom sheets on larger screens like tablet have a max width that can be overridden_
_altText: A bottom sheet extended to its max-width on a large screen device, not spanning the full screen._

On larger expanded breakpoints, like desktop, a bottom sheet can be swapped for a side sheet that shows similar content.

_footer: Side sheets can contain the same content as bottom sheets and may be more suitable for desktop_
_altText: A side sheet on desktop._

## Behavior

Bottom sheets can offer an expansion option where the sheet is fully raised and toggled between a collapsed and expanded state. This provides a more predictable footprint of the sheet, and can be set by the system or toggled by the user.

_footer: A bottom sheet for sharing can appear fully raised if needed_
_altText: Bottom sheet fully raised, showing photo actions, sharing options, and albums to add the photo to._

_footer: Alternately, a bottom sheet for sharing can appear collapsed for a more focused set of actions_
_altText: Collapsed bottom sheet, showing focused set of options._

### Custom positioning

The drag handle can be dragged or selected to change the bottom sheet height. 

Sheets should be able to cycle through preset heights and close completely without dragging. Selecting the drag handle should toggle through preset heights or close the sheet, while selecting the scrim should always close the bottom sheet.

If the bottom sheet has multiple preset heights but can’t use a drag handle, Material requires the inclusion of a single-pointer alternative to change height.

_footer: Interacting with the drag handle can quickly move a bottom sheet through preset heights_
_altText: Bottom sheet with a visible drag handle that can be used to adjust its height._

_footer: A bottom sheet can automatically resize to another height after interacting with the drag handle_
_altText: Bottom sheet resized using the visible drag handle._

### Scrolling

Bottom sheets can be horizontally scrolled, independent of the rest of the screen’s content.

_footer: Bottom sheets should be scrollable when their content exceeds the initial viewable height_
_altText: Bottom sheet that can be scrolled horizontally._

### Back

On Android, a gesture called predictive back allows a user to swipe left or right on the bottom sheet. 

- Bottom sheet detaches from the left and right edges of the screen to signal it will close
- Previous screen is revealed in a preview

A list of compatible components is available in the [gestures article](/m3/pages/gestures).

_footer: Preview of the result of the gesture, **release** to commit, **fling** to commit, and **cancel**_

<!-- section: Accessibility -->

## Use cases

Users should be able to:

- Resize bottom sheets without having to rely on touch gestures

## Interaction & style

### Touch target area

The top 48dp portion of the bottom sheet is interactive when user-initiated resizing is available and the drag handle is present.

_footer: To ensure touch target accessibility, the top portion of a bottom sheet can be reserved for resize interactions_
_altText: Touch target area of a bottom sheet._

### Initial focus

The optional drag handle can be focused in the tab order and interacted with using non-touch inputs, such as keyboard or switch controls.

_footer: Visible focus shown on the drag handle affordance_
_altText: Focus on the drag handle of a bottom sheet._

### Dragging

Include a single-pointer alternative for any action that can be completed by dragging.

Drag handles should cycle the bottom sheet through available heights when selected. If a drag handle can’t be used, add a button to do this action.

_footer: Interacting with the drag handle can quickly move a bottom sheet through preset heights_
_altText: Bottom sheet with focused drag handle at lower preset height._

_footer: A bottom sheet can automatically resize to another height after interacting with the drag handle_
_altText: Bottom sheet with drag handle at higher preset height._

## Keyboard navigation

Keys | Actions |
Tab | Focus lands on drag handle |
Space / Enter | Toggles between available heights |

## Labeling

Label only the drag handle. The accessibility role for the drag handle is “button.”

_footer: Label the drag handle_
_altText: Labeled drag handle with role of button._

---

<!-- Source: m3.material.io · components_side-sheets · updated 2026-07-28T07:57:48.089Z · CC-BY 4.0 (Google) -->

## Side sheets



<!-- section: Overview -->

-
Use side sheets to provide optional content and actions without interrupting the main content

-
Two variants: standard and modal

-
People can navigate to another region within the sheet

-
Side sheets can contain a back icon for navigation

_footer: - Standard side sheet - Modal side sheet_
_altText: The 2 variants of side sheets._

## Availability & resources

## Differences from M2

-
Right-to-left (RTL) language support with left side sheet

-
Color: New color mappings and compatibility with dynamic color

-
Shape: Modal side sheets have a 16dp corner radius

_footer: Side sheets have new color mappings to support dynamic color_
_altText: A modal side sheet showing the 16dp corner radius._

<!-- section: Specs -->

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Standard side sheet

_footer: - Divider (optional) - Headline - Container - Close icon button_
_altText: 4 elements of a standard side sheet._

### Standard side sheet color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Side sheet color roles used for light and dark themes:  - Outline variant - On surface variant - Surface - On surface variant_
_altText: 4 color roles applied to a side sheet in light and dark themes._

### Standard side sheet measurements

_footer: Side sheet padding and size measurements_
_altText: Standard side sheet padding and size measurements._

Attribute
 | Value
 |
Start/end padding
 | 24dp |
Padding between top elements
 | 12dp |
Bottom actions height
 | 72dp |
Bottom actions top padding
 | 16dp |
Bottom actions bottom padding
 | 24dp |
Bottom actions alignment (horizontal)
 | Left |
Max-width
 | 400dp |
Margins (when detached)
 | 16dp |

## Modal side sheet

_footer: - Back icon button (optional) - Headline - Container - Close icon button - Divider (optional) - Action buttons (optional) - Scrim_
_altText: 7 elements of a modal side sheet._

### Modal side sheet color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/).

_footer: Side sheet color roles used for light and dark themes:  - On surface variant  - On surface variant  - Surface container low  - On surface variant_
_altText: 4 color roles applied to a modal side sheet in light and dark themes._

### Modal side sheet measurements

_footer: Modal side sheet padding and size measurements_

Attribute
 | Value
 |
Start/end padding
 | 24dp |
Start padding with icon | 16dp |
Padding between top elements | 12dp |
Bottom actions height
 | 72dp |
Bottom actions top padding
 | 16dp |
Bottom actions bottom padding | 24dp |
Bottom actions alignment (horizontal)
 | Left |
Max-width
 | 400dp |
Margins (when detached)
 | 16dp |

<!-- section: Guidelines -->

_footer: - Standard side sheet - Modal side sheet_
_altText: Side by side comparison of a standard and a modal side sheet._

## Usage

Standard side sheets are supplementary surfaces used mostly in medium to expanded breakpoints, like tablet and desktop. They provide a consistent and predictable surface for contextual actions and information.

Standard side sheets display content that complements the screen’s primary content. They remain visible while people interact with primary content.

Common uses include:

-
Displaying a list of actions that affect the screen’s primary content, such as filters

-
Displaying supplemental content and features

_footer: Information about a photo in a standard side sheet_
_altText: Standard side sheet showing supplementary information about a photo._

Modal side sheets are preferred in compact breakpoints, like mobile, due to limited screen size. 

They can display the same kinds of content as standard side sheets, but must be dismissed in order to interact with the underlying content.

_footer: Modal side sheet with filter controls_
_altText: Modal side sheet showing filter controls._

Side sheets have a fixed width and typically span the height of the screen. 

Their dimensions depend on how the app’s layout is subdivided into UI regions.

_footer: Place side sheets along the edge of the screen, usually on the right side to avoid interference with any navigational components on the left edge. They can be slightly inset by 16dp._
_altText: A modal sheet at the right of a screen, with the correct inset._

_footer: Don’t inset a side sheet from the screen edges far beyond the recommended margin. This makes the sheet’s position and scroll behavior unclear, while obscuring primary content._
_altText: A modal side sheet at the right of the screen with the wrong inset._

## Anatomy

_footer: - Divider (optional) - Headline - Container - Close icon button_
_altText: 4 elements of a standard side sheet._

_footer: - Back icon button (optional) - Headline - Container - Close icon button - Divider (optional) - Action buttons (optional) - Scrim_
_altText: 7 elements of a modal side sheet._

### Container

Side sheet containers hold all side sheet elements. Their size is determined by the space those elements occupy.
 
The container is the only required element of a side sheet.

_footer: - Container_
_altText: A modal side sheet’s container._

### Back icon button (optional)

Icon buttons can provide ways to exit a side sheet or move to a different experience.

Because the primary content behind or beside a side sheet is always visible, it’s important to provide affordances for leaving a side sheet and returning to the primary content.

_footer: - Back icon button_
_altText: Back icon button on the upper left of a modal side sheet._

### Close icon button (optional)

A close affordance provides a consistent method for dismissing a side sheet. 

A close icon button is highly recommended, increases accessibility, and makes focused side sheets easier to close.

_footer: - Close icon button_
_altText: Close icon button on the upper right of a modal side sheet._

### Action buttons (optional)

Buttons represent actions available from a side sheet. Examples: **Save**, **Edit**, **Download**

Use elevation, fill, and tone to call attention to specific actions.

_footer: - Action buttons_
_altText: Save and cancel buttons at the bottom of a modal side sheet._

### Divider (optional)

Dividers can separate different kinds of content and create distinct regions in a side sheet. 

Use a divider to separate:

-
Action buttons from content

-
User-generated content from system-generated content

_footer: - Divider_
_altText: Horizontal divider on a modal side sheet._

### Content (optional)

Side sheets can display a wide variety of content and layouts, ranging from a list of actions to supplemental content in a tabular layout.

_footer: Form controls shown in a side sheet for app settings_
_altText: 2 side sheets with different content displayed side by side._

_footer: Modal side sheets on smaller screens can transition to standard side sheets at larger screen sizes_
_altText: As a small screen changes to a larger size the modal side sheet transitions to a standard side sheet._

## Adaptive design

Side sheets have a default width, but can be resized depending on the needs of the layout. 

When a standard side sheet opens, the body area shrinks to accommodate the sheet’s width while maintaining a margin on the body’s trailing edge.

_footer: Entrance of standard side sheets will cause the body area to adjust and accommodate the new content_
_altText: Body area of a screen adjusts to accommodate entrance and exit of side sheet._

### RTL language support

In right-to-left (RTL) languages, side sheets should appear on the left edge of the window with all elements reversed.

_footer: Side sheet elements are reversed in RTL languages_
_altText: Side sheet along the left edge of a screen. All buttons and icons are reversed._

## Behavior

Side sheets can vertically scroll independent of the rest of the UI. 

This allows their scroll position and content to persist while the page is scrolled, and vice versa.
Side sheets cannot scroll horizontally.

_footer: Side sheets can vertically scroll internally when their content exceeds the screen height_
_altText: Animation showing a side sheet being scrolled vertically to view all the options._

_footer: Don’t allow horizontal scrolling or lay out the side sheet in a way that suggests horizontal scrolling. A side sheet’s narrow width leaves limited space to fully view items._
_altText: A side sheet appears to scroll horizontally._

### Predictive back

On Android, a gesture called [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md) allows a person to swipe left or right on the side sheet. 

When predictive back is used:

-
The side sheet detaches from the top and bottom edges of the screen to signal it will close

-
The previous screen is revealed in a preview

-
The side sheet and its content always scales in the direction of the gesture

[Find a list of compatible components](/m3/pages/gestures#22462fb2-fbe8-4e0c-b3e7-9278bd18ea0d)

_footer: Preview of the result of the gestures: release to commit, fling to commit, and cancel_
_altText: Swiping to go back shows a preview of the previous screen._

<!-- section: Accessibility -->

## Use cases

People should be able to dismiss the side sheet using assistive technology.

## Interaction & style

Material requires that a close affordance, such as a close icon button, is always present within a side sheet.

_footer: A close icon button makes the side sheet easy to dismiss_
_altText: Side sheet correctly designed with close icon in upper right corner._

_footer: Without a close icon button, people can’t predict the opening and closing flow of side sheets, or know if the sheet is transient or permanent_
_altText: Side sheet incorrectly designed with no close icon button._

## Initial focus

Actions within a side sheet can be focused by tab order using a keyboard or switch control.

_footer: Visible focus shown on the available actions within a side sheet:  - Headline - Close - Cancel - Save_
_altText: Side sheet diagram showing the focus order of headline, close, save, cancel._

## Keyboard navigation

Keys
 |
Actions
 |

**Tab**
 |
Focus lands on (non-disabled) icon button

 |

**Space** or **Enter**
 |
Activates the (non-disabled) icon button
 |

## Labeling

The accessibility role for a side sheet is **Dialog**.

_footer: The role for side sheets is **Dialog**_
_altText: Side sheet showing the accessibility role as dialog._

---

<!-- Source: m3.material.io · components_dialogs · updated 2026-07-28T07:11:33.307Z · CC-BY 4.0 (Google) -->

## Dialogs



<!-- section: Overview -->

-
Use dialogs to make sure users act on information

-
Two variants: basic and full-screen

-
Should be dedicated to completing a single task

-
Can also display information relevant to the task

-
Commonly used to confirm high-risk actions like deleting progress

_footer: - Basic dialog - Full-screen dialog_
_altText: Basic and full-screen dialog._

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Layout: Greater padding to account for the increased corner-radius and title size
- Position: Option for custom basic dialog positioning
- Shape: Increased corner-radius
- Typography: Larger and darker headline

_footer: New updates to color, layout, position, shape, and typography_
_altText: Basic dialog with rounded corner, larger headline._

<!-- section: Specs -->

## Tokens & specs

Select a component variant below to see its elements, attributes, tokens, and their values.

## Basic dialogs

_footer: - Container - Icon (optional) - Headline (optional) - Supporting text - Divider (optional) - Button label text - Scrim_
_altText: Anatomy diagram numbering dialog elements._

### Basic dialog color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Basic dialog color roles used for light and dark themes:  - Surface container high - Secondary - On surface - On surface variant - Primary - Scrim_
_altText: Color mapping diagram labeling 6 color roles across the dialog and scrim._

### Basic dialog measurements

_footer: Basic dialog padding and size measurements_
_altText: Annotated diagram showing padding values._

Attribute | Value |
Container shape
 | 28dp corner radius |
Container height
 | Dynamic |
Container width
 | Min 280dp; Max 560dp |
Divider height
 | 1dp |
Icon size
 | 24dp |
Minimum width
 | 280dp  |
Maximum width
 | 560dp |
Alignment with icon
 | Center-aligned |
Alignment without icon
 | Start-aligned |
Top/Left/right/bottom padding
 | 24dp |
Padding between buttons
 | 8dp |
Padding between title and body
 | 16dp |
Padding between icon and title
 | 16dp |
Padding between body and actions
 | 24dp |

## Full-screen dialogs

_footer: - Container - Header - Icon (close affordance) - Headline (optional) - Text button - Divider (optional)_
_altText: Diagram numbering 6 full-screen dialog elements._

### Full-screen dialog color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value.

_footer: Full-screen dialog color roles used for light and dark themes:  - Surface container high - On surface - On surface - Primary - On surface variant_
_altText: Color mapping diagram shows 5 callout markers across the dialog._

### Full-screen dialog measurements

_footer: Full-screen dialog padding and size measurements_
_altText: Diagram noting layout measurements for padding values, title, height, and action regions._

Attribute | Value |
Container shape
 | 0dp corner radius |
Container height
 | Dynamic |
Container width
 | Container width; Max 560dp |
Header height
 | 56dp |
Header width
 | Container width |
Headline text alignment
 | Start-aligned |
Divider height
 | 1dp |
Icon (close affordance) size
 | 24dp |
Bottom action bar height
 | 56dp |
Bottom action bar width
 | Container width |
Top/left/right padding
 | 24dp |
Padding between elements
 | 8dp |

<!-- section: Guidelines -->

_footer: A basic dialog_
_altText: Basic dialog in isolation_

## Usage

A dialog is a modal window that appears in front of app content to provide critical information or ask for a decision. Dialogs disable all app functionality when they appear, and remain on screen until confirmed, dismissed, or a required action has been taken.

Dialogs are purposefully interruptive, so they should be used sparingly. A less disruptive alternative is to use a dropdown menu, which provides options without interrupting a user’s experience.

_footer: There are two variants of dialogs:  - Basic dialog  - Full-screen dialog_
_altText: Diagram of basic and full-screen dialogs._

_footer: Use dialogs for prompts that block an app’s normal operation, and for critical information that requires a specific user task, decision, or acknowledgement_
_altText: Dialog in front of app content._

_footer: Don’t use dialogs for low- or medium-priority information. Instead use a snackbar, which can be dismissed or disappear automatically._
_altText: Low-priority dialog in front of app content._

### Similar components

Snackbars are also designed to show important messages.

Choose the right component based on the importance of the message. This component messaging strategy helps avoid overusing dialogs.

_footer: Snackbars can disappear automatically_
_altText: Snackbar on a phone saying that new photos were synced to the device. No buttons exist._

Component | Importance | Action needed |
Snackbar | Low importance | Optional: Snackbars may not have a button, and can disappear automatically |
Dialog | High importance | Required: Dialogs block the main content until an action is confirmed |

## Anatomy

### Basic dialog

_footer: - Container - Icon (optional) - Headline (optional) - Supporting text - Divider (optional) - Buttons label text - Scrim_
_altText: Diagram of 7 elements of basic dialog._

### Full-screen dialog

_footer: - Container - Header region - Icon (close affordance) - Headline (optional) - Button label text - Divider (optional)_
_altText: 6 elements of full-screen dialog._

### Container and scrim

Dialog containers appear above other screen elements and hold the dialog’s headline, text, buttons, and list items.

To focus attention on the dialog, surfaces behind the container are scrimmed with a temporary overlay to make them less prominent.

_footer: Basic dialogs appear over a background scrim_
_altText: Basic dialog shown above a scrim overlay that reduces the prominence of the background elements._

### Headline (optional)

A dialog’s purpose should be communicated by its headline and buttons or actionable items.

Headlines should:

- Contain a brief, clear statement or question
- Avoid apologies (“Sorry for the interruption”), alarm (“Warning!”), or ambiguity (“Are you sure?”)

_footer: This dialog title poses a specific question, concisely explains what’s involved in the request, and provides clear actions_
_altText: Dialog title asking “Use location service?”_

_footer: Don’t use dialog titles that pose an ambiguous question_
_altText: Dialog title asking “Are you sure?”_

Headlines should always be succinct. They can wrap to a second line if necessary, and be truncated.

In full-screen dialogs, long headlines or headlines of variable lengths (such as translations), can be placed in the content area instead of the app bar.

_footer: Avoid placing long headlines in a full-screen dialog’s app bar (1), as the truncated text may lead to misunderstanding_
_altText: Example full-screen dialog with truncated long headline._

_footer: Find ways to shorten app bar text, and place longer headlines into the content area (1) of a full-screen dialog_
_altText: Example full-screen dialog with short headline, and longer text in content area._

### Buttons

Dialog actions are most often represented as buttons and allow users to confirm, dismiss, or acknowledge something.

Buttons are aligned to the trailing edge of the dialog for easier interaction. The confirmation button is always closest to the edge. 

Button alignment responds automatically for right-to-left languages, where the confirmation button is aligned to the left edge.

_footer: Disable confirming actions (1) until a choice is made. Dismissive actions are never disabled._
_altText: Dialog with the confirmation button disabled because a required radio selection is missing._

_footer: Don’t place dismissive actions (1) to the right of confirming actions. Instead, place them to the left of confirming actions._
_altText: Dialog with the dismissing action "Cancel" on the right of the 2 buttons._

_footer: A single action may be provided only if it’s an acknowledgement_
_altText: Dialog with a single-action button: “OK”._

_footer: Avoid presenting people with unclear choices. **Cancel** doesn't make sense here because no clear action is proposed._
_altText: Dialog with 2 button choices: “Cancel”, “Got it”._

Dialogs should contain a maximum of two actions.

- If a single action is provided, it must be an acknowledgement action
- If two actions are provided, one must be a confirming action, and the other a dismissing action

_footer: Display two text buttons next to one another_
_altText: Dialog with 2 buttons side-by-side: “Disagree”, “Agree”._

_footer: Stacked buttons accommodate longer button text, but take up more room. Confirming actions appear above dismissive actions._
_altText: Dialog with 2 stacked buttons: “Turn on speed boost”, “No thanks”._

Providing a third action, such as **Learn more**, is not recommended as it navigates the user away from the dialog, leaving the dialog task unfinished.

Rather than adding a third action, an inline expansion can display more information. If more extensive information is needed, provide it prior to entering the dialog.

_footer: The **Learn more** action (1) navigates away from this dialog, potentially leaving it in an indeterminate state_
_altText: Dialog with 3 text buttons: Learn more, Disagree, Agree._

## Basic dialog

Basic dialogs interrupt users with urgent information, details, or actions. Common use cases for basic dialogs include alerts, quick selection, and confirmation.

_footer: Basic dialogs require a person to take action before it will close_
_altText: Example of basic dialog action request._

_footer: Basic dialogs can give people the ability to provide confirmation of a choice before committing to it_
_altText: Example of basic dialog confirmation._

Basic dialogs most often appear as alerts or lists, but can have a variety of layouts and component combinations, including lists, date pickers, and time pickers.

_footer: Date picker dialogs allow people to tap a date, then confirm it by tapping **OK**_
_altText: Date picker dialog._

_footer: Time picker dialogs allow people to move the clock hand and then confirm by tapping **OK**_
_altText: Time picker dialog._

## Full-screen dialog

Full-screen dialogs fill the entire screen, containing actions that require a series of tasks to complete. One example is creating a calendar entry with the event title, date, location, and time.

Because they take up the entire screen, full-screen dialogs are the only dialogs over which other dialogs can appear.

Use a [container transform](/m3/pages/motion-transitions/transition-patterns#b67cba74-6240-4663-a423-d537b6d21187) pattern to transition a FAB into a full-screen dialog.

_footer: Full-screen dialogs contain actions that require a series of tasks to complete_
_altText: A FAB transitioning into a full-screen dialog._

When a full-screen dialog is closed without being saved, a basic dialog appears in front of it to confirm selections should be discarded without saving changes.

_footer: A basic modal dialog appears when a full-screen dialog is closed without being saved_
_altText: Closing a full-screen dialog triggers a basic dialog asking to discard the changes._

Full-screen dialogs may be used for content or tasks that meet any of these criteria:

-
Dialogs that include components which require keyboard input, such as form fields

-
When changes aren’t saved instantly

-
When components within the dialog open additional dialogs

Full-screen dialogs are for compact breakpoints only, like mobile devices. For medium and expanded breakpoints, use a basic dialog.

### Saving selections

To save a selection in a full-screen dialog, use **Save**.  The close icon or dismissive action, such as **Cancel** or **Back**, should close the dialog.

### Confirmation

The confirmation action should be clear about what happens next, like **Send** or **Create**. Avoid using vague terms like **Done**, **OK**, or **Close**. Only trigger an additional basic dialog if the action fails. Don’t disable the confirmation button.

_footer: A **Create** button is clear that the event will be created_
_altText: Full-screen dialog with create button as confirmation action._

_footer: Don’t trigger a basic dialog when the confirming action is selected_
_altText: Full-screen dialog with an additional basic dialog asking if you want to create this event._

### Dismissing

When someone dismisses a full-screen dialog, a basic dialog should appear to confirm that they want to discard the unsaved changes.

_footer: Use a basic dialog to confirm that the user wants to discard unsaved changes_
_altText: A basic dialog with options to either keep editing or discard unsaved changes._

_footer: Don’t use the confirming action to dismiss the full-screen dialog_
_altText: A full-screen dialog with a Close button as the confirming action._

### Error messages

Errors about the dialog fields should always appear inline where they occur. Some components like text fields have built-in error messaging, while others like checkboxes and radio buttons need error messages to be added next to the fields.

General errors such as network issues preventing saving or submitting should appear in a basic dialog when the confirming action fails.

Error messages should clearly but briefly explain the source of the error and how to fix it. Show all errors on the page at once so people can fix everything before trying again.

_footer: Error messages related to the fields should be displayed inline_
_altText: A full-screen dialog with inline error messages for text fields._

_footer: Errors unrelated to the fields can be displayed in a basic dialog_
_altText: A basic dialog mentioning that entries were not saved due to a connection issue._

### Dialog windows

Launching a full-screen dialog temporarily resets the app’s perceived elevation, allowing simple menus or dialogs to appear above the full-screen dialog. They cover the screen and don’t appear as a floating modal window.

### Navigation

Because full-screen dialogs can only be completed, dismissed, or closed, the close “X” icon button should be the only navigation option in the app bar.

## Adaptive design

Dialogs can swap variants as the breakpoint changes. For example, a full-screen dialog can change into a basic dialog at larger breakpoints.

_footer: - Full-screen dialog on mobile - Dialog on a tablet_
_altText: Example of full-screen dialog on left, simple dialog on right_

### Medium breakpoint

Basic dialogs appear in a center position by default.

Their position can be overridden to provide a more ergonomic experience.

_footer: Dialog custom positioned on the right side of the screen_
_altText: Basic dialog on tablet photos app._

### Expanded breakpoint

Dialogs on expanded breakpoints, like desktop, are modal windows above a scrim. This puts the dialog at the forefront of a person's view, calling attention to the action prompted in the dialog.

_footer: Desktop dialogs call attention to the required action_
_altText: Example of desktop dialog._

Basic dialogs can be custom-positioned anywhere on larger screens, respecting margins to prevent edge collision.

_footer: Custom placement area for basic dialogs that respects a 56dp margin from the edges of the screen_
_altText: Basic dialog position diagram._

## Behavior

### Appearing

Dialogs appear without warning, requiring users to stop their current task. They should be used sparingly, as not every choice or setting warrants interruption.

Dialogs use an [enter and exit](/m3/pages/motion-transitions/transition-patterns#e1c2a650-d7a4-4a6d-9025-e6b7845291ed) transition pattern to appear on screen.

_footer: A dialog appears with an enter and exit transition_
_altText: Dialog entering and exiting screen using fade transition._

### Position

Dialogs retain focus until dismissed or an action has been taken, such as choosing a setting. They shouldn’t be obscured by other elements or appear partially on screen, with the exception of full-screen dialogs.

_footer: Dialogs shouldn’t be obscured by other elements except for full-screen dialogs_
_altText: A basic dialog covering a full-screen dialog._

### Scrolling

Most dialog content should avoid scrolling. Even when scrolling is required, the dialog title is pinned at the top, with buttons pinned at the bottom. This ensures selected content remains visible alongside the title and buttons, even upon scroll.

Dialogs don’t scroll with elements outside of the dialog, such as the background.

_footer: When viewing a scrollable list of options, the dialog title and buttons remain fixed_
_altText: Example of fixed dialog title and buttons._

starNote:This is a rapidly changing space. Guidelines are primarily intended for designers at this time. Find what’s implemented in code in the [design kit](https://www.figma.com/community/file/1035203688168086460).

Extended reality (XR) introduces spatial capabilities, such as using depth to make dialogs stand out from the background. Currently, spatial dialogs are only available in full space. For home space, follow Material’s general [dialog guidance](/m3/pages/dialogs/guidelines#b33988d3-88e6-432c-acb1-4461a84171c9).

## Color & elevation

XR uses [color roles](/m3/pages/color-roles/tab-1#89f972b1-e372-494c-aabc-69aea34ed591) to communicate the elevation of UI elements. Dialogs can use two color options: **surface container high** or **surface container highest**.

starNote:Color and elevation for spatial dialogs can be customized by makers and are not available in Jetpack Compose yet.

_footer: - Surface container high - Surface container highest_
_altText: 2 spatially elevated dialogs with surface-container-high and surface-container-highest color roles._

For effective visual hierarchy, a dialog should be the most prominent element. 

Add a scrim behind a dialog to improve its visibility. Scrims prevent other content from being selected until the dialog action is complete.

_footer: Make sure a spatial dialog’s color is higher than all other UI elements, and use a scrim_
_altText: Dialog with surface-container-highest color and a scrim._

The dialog should have the highest elevation in the product.

For example, if a dialog is **surface container high**, don’t use **surface container highest** for any other elements.

_footer: If a dialog’s color is **surface container high**, don’t use **surface container highest** for any other element_
_altText: Dialog with surface-container-high color and no scrim. An orbiter is at a higher elevation than the dialog._

## Usage

[Basic dialogs](/m3/pages/dialogs/guidelines#97ac3858-3932-4084-ae8e-73e42b7cb752) are recommended when designing for XR’s expanded window sizes. This keeps the required action in the person’s [field of view](https://developer.android.com/design/ui/xr/guides/spatial-ui#where-place). Limit use of [full-screen dialogs](/m3/pages/dialogs/guidelines#007536b9-76b1-474a-a152-2f340caaff6f) to compact window sizes, like mobile devices.

_footer: A basic dialog elevated above an app in home space_
_altText: Basic dialog in XR._

_footer: Avoid using full-screen dialogs in XR. Required actions could appear beyond a person’s field of view._
_altText: Full-screen dialog in XR._

## Spatial dialogs

In full space, dialogs can be elevated spatially via [overrides](https://developer.android.com/develop/xr/jetpack-xr-sdk/material-design#use-enablexrcomponentoverrides). This helps dialogs stand out from their background in XR.

_footer: Side view of a basic dialog with spatial elevation in full space_
_altText: Side view of basic dialog showcasing spatial elevation._

## Behavior

### Effect

The spatial dialog should scale uniformly. It also fades in when appearing, and fades out when disappearing. 

The dialog's scrim only fades in and out.

_footer: Front view of a spatial dialog in motion in full space_
_altText: A direct view of a spatial dialog appearing and disappearing._

### Movement

When activated, the spatial dialog rises from the app to the highest resting level on the Z-axis. 

When the action is complete, it returns to a normal resting level.

The dialog's scrim stays at the app content level at all times. 

To prevent motion sickness, use [standard easing](/m3/pages/motion-easing-and-duration/tokens-specs#601d5552-a6e6-4d74-9886-ff8f24b9ec35) and [long duration](/m3/pages/motion-easing-and-duration/tokens-specs#48bf653e-46f9-48f5-87e0-eaf8ea3fe716) motion tokens.

_footer: Side view of a spatial dialog in motion in full space_
_altText: A spatial dialog elevating on the Z-axis, as seen from a side angle._

## Placement

Consider factors like field of view, viewing distance, and possible interactions when deciding where to place dialogs in XR.

### Elevation: highest resting level

Display spatial dialogs at the highest resting level. When setting the depth value of the highest resting level, make sure the elevated dialog is at a comfortable viewing distance from the person. [More on spatial elevation](https://developer.android.com/design/ui/xr/guides/spatial-ui#spatial-elevation)

_footer: A spatial dialog moves to the highest resting level in full space_
_altText: An animated side view of a dialog moving from the lowest to the highest resting level._

### Center spatial dialogs in field of view

Spatial dialogs should be centered in a person’s [field of view](https://developer.android.com/design/ui/xr/guides/spatial-ui#where-place). If the dialog **can't** track head movements, position it in the center of the app’s content. 

If the dialog **can** track head movements, configure it with a lazy follow behavior. This keeps the dialog anchored to the center of a person’s field of view until an action is taken.

_footer: A dialog in full space stays centered in a person’s field of view_
_altText: A dialog follows a person’s head movements, remaining centered in their field of view._

## Accessibility considerations

[XR accessibility](https://developer.android.com/design/ui/xr/guides/get-started#make-app) guidelines are still evolving. Spatial dialogs should follow applicable Material [dialog accessibility standards](/m3/pages/dialogs/accessibility).

<!-- section: Accessibility -->

## Use cases

People should be able to use assistive technology to:

- Open and close a dialog
- Provide and submit other inputs if the dialog is interactive, such as a text field or selectable list
- Scroll the dialog to access all of its contents if that content extends beyond the container of the dialog

## Interaction & style

### Use sparingly

Dialogs are purposefully interruptive. This means they appear in front of app content and disrupt the flow of content for people who may, for example, be using a screen reader to navigate the page.

As such, dialogs should be used sparingly and only to provide critical information. Less critical information should be presented in a non-blocking way within the flow of app content.

_footer: Present non-critical information using other UI within the flow of app content_
_altText: An inline tooltip doesn’t block a photo app’s content on a mobile screen. A modal dialog blocks the content of a photo app on a mobile screen._

_footer: Avoid putting non-critical information in a dialog_
_altText: A modal dialog blocks the content of a photo app on a mobile screen. A modal dialog blocks the content of a photo app on a mobile screen._

### 200% text size

Avoid excessive text wrapping or truncation by choosing concise strings. 

On Android, headlines should be kept concise enough to fit within **four** lines after the text size is increased to 200%. If a headline exceeds this limit and gets truncated, provide an alternative way to access the full content in a single tap.

_footer: Avoid excessive text wrapping or truncation by choosing concise strings_
_altText: A dialog with 200% text wraps multiple times in the header and description. It covers most of the mobile screen._

### Elements within dialogs

Because dialogs can contain various elements within them, refer to the relevant accessibility guidelines for each element. 

Some common examples include:

- Text fields
- Typography
- Buttons

_footer: Full-screen dialogs can contain various elements such as (1) text fields, (2) typography, and (3) buttons, which each may have their own accessibility guidelines_
_altText: 3 elements of a full-screen dialog._

## Initial focus

When a dialog appears, focus should automatically land on the first interactive element within the dialog.

_footer: Initial focus lands on the first interactive element within a dialog. The tab key moves focus through the next interactive elements in a cycle._
_altText: A modal dialog titled “Permanently delete?” whose second interactive element is focused by selecting the Tab key._

_footer: The shift and tab keys together move focus in the opposite direction. The space or enter key triggers or commits the action of the focused element._
_altText: A modal dialog titled “Permanently delete?” whose previous interactive element is focused on by selecting both the Shift and Tab keys._

## Keyboard navigation

Keys | Actions |
Tab | Focus lands on the next interactive element contained in the dialog, or the first element if focus is currently on the last element |
Shift + Tab
 | Focus lands on the previous interactive element contained in the dialog, or the last element if focus is currently on the first element |
Space or Enter
 | Triggers or commits the action of the focused element |
Escape
 | Closes the dialog |

## Labeling elements

The accessibility label for a dialog is typically the same as the dialog’s title or headline.

On web, basic dialogs should have the **alert dialog** role.

_footer: Basic dialogs are known as alert dialogs on web_
_altText: An alert dialog with a title “Set up traffic updates?”  Its label is “Set up traffic updates?” and its role as “Alert Dialog.”_

Components contained within the dialog, such as buttons, should be labeled according to the guidelines specific to those components.

For common examples, see:

- Buttons
- Text fields

_footer: Elements within a dialog should be labeled according to their guidelines_
_altText: A full-screen dialog titled “New event” containing a “Save” button and a text field, both with their own accessibility labels._

---

<!-- Source: m3.material.io · components_divider · updated 2026-07-17T07:13:07.955Z · CC-BY 4.0 (Google) -->

## Divider



<!-- section: Overview -->

- Make dividers visible but not bold
- Only use dividers if items can’t be grouped with open space
- Use dividers to group things, not separate individual items

_footer: Dividers separating items in a list_
_altText: Screen shot of five stacked dividers_

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Configurations: Ability to have vertical dividers

_footer: Dividers have new color mappings_
_altText: Screen shot of three dividers_

<!-- section: Specs -->

_footer: - Divider_
_altText: Diagram of divider set on horizontal line_

## Tokens and specs

Browse the component elements, attributes, tokens, and their values.

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/825906c9-6eed-47d1-8812-450910c1356e)

_footer: Divider color roles used for light and dark schemes:  - Outline variant_
_altText: Divider on light background and dark background._

## Measurements

_footer: Measurements_
_altText: Divider's measurement._

Attribute | Value |
Divider full-width
 | 100% |
Divider inset left margin
 | 16dp |
Divider inset right margin
 | 0dp |
Divider middle-inset left margin
 | 16dp |
Divider middle-inset right margin
 | 16dp |
Space between divider & supporting-text
 | 4dp |
Divider right margin
 | 8dp |
Divider bottom margin | 8dp |

<!-- section: Guidelines -->

_footer: Full-width dividers_
_altText: Inbox app using full-width dividers to separate messages._

## Usage

Dividers are one way to visually group components and create hierarchy. They can also be used to imply nested parent/child relationships.

The divider can be used in two ways: 

-
Full width

-
Inset

_footer: Full-width divider_
_altText: Inbox app using full-width dividers to separate messages._

_footer: Inset divider_
_altText: Music app using inset dividers to separate songs in a playlist._

## Anatomy

A divider is a simple line.

_footer: - Divider_
_altText: Illustration of a divider._

## Full-width dividers

Use full-width dividers to separate larger sections of unrelated content. They can be used directly on a surface or inside other components like cards or lists.

Full-width dividers can also separate interactive areas from non-interactive areas. 

They are used to group visual elements together, and indicate when elements are related to each other from an interaction perspective.

_footer: Full-width dividers to indicate separation of content_
_altText: Inbox messages visually separated by full-width dividers for improved readability._

_footer: Use full-width divider lines to separate interactive and non-interactive areas of a container such as a card_
_altText: Non-interactive information on a card and a clickable read more link separated by a full-width divider._

_footer: Use full-width dividers sparingly. Too many divider lines will make an interface look cluttered._
_altText: Full-width dividers used after every piece of content on a page._

## Inset dividers

Use inset dividers to separate related content within a section.

Inset dividers are equally indented from both sides of the screen by default.

_footer: Inset dividers separate related content, such as emails in a list. They should be used with anchoring elements such as icons or avatars, and align with the leading edge of the screen._
_altText: 2 different content sections separated by an inset divider._

_footer: Inset dividers in a list of related items_
_altText: 3 types of related content separated by inset dividers on a mobile screen._

_footer: Inset dividers can be placed in the middle of a layout to separate elements such as body text from selection chips_
_altText: Inset divider separating body text and selection chips._

### Using dividers both ways on the same screen

If dividers are used both ways in a UI, they must reinforce the hierarchy of information within different sections.

-
To separate a different kind of content, use a full-width divider

-
To separate nested content items, use inset dividers

_footer: Use a combination of inset and full-width dividers to reflect the hierarchy of information_
_altText: Dividers used to show content hierarchy: full-width for sections, inset for related items._

List items with repetitive formats may not require an inset divider, in which using only the margin between items is acceptable.

_footer: Content may not require a divider line_
_altText: List with repetitive item formats. Visual separation achieved through margins only._

## Vertical divider

A vertical divider can be used to arrange content on a larger screen, such as separating paragraph text from video or imagery media.

_footer: Vertical divider in a large screen context_
_altText: Image and text side-by-side, separated by a vertical divider on a large screen._

<!-- section: Accessibility -->

Dividers are decorative elements, which have no contrast minimums.

_footer: Decorative elements have no contrast minimums_
_altText: Divider separating messages in an inbox that are already separated with type styles and spacing is annotated as decorative._
