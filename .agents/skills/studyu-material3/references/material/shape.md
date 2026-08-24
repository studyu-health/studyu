# Material 3 · Shape

<!-- Source: m3.material.io · styles_shape · updated 2026-07-17T05:28:54.725Z · CC-BY 4.0 (Google) -->

## Shape

> The M3 shape system includes original shapes, a corner radius scale, and built-in shape morphing



<!-- section: Overview & principles -->

- Use abstract shapes thoughtfully to add emphasis and decorative flair
- Leverage Material shapes for built-in shape morphing
- Rectangular shapes are fully rounded in all corners by default
- Individual corners can be adjusted to create asymmetrical rectangular shapes

_footer: Abstract shapes can help people express themselves_
_altText: Illustration of range of irregular shapes._

## Availability & resources

Type
 |
Resource
 |
Status
 |

Design
 |
[Shape library](http://figma.com/community/file/1035203688168086460/material-3-design-kit) (Figma Design Kit)

 |
Available
 |

Implementation
 |
[Jetpack Compose](https://developer.android.com/reference/kotlin/androidx/compose/material3/MaterialShapes) (Shape Library)
 |
Available
 |

[Android Views (MDC-Android)](https://github.com/material-components/material-components-android/blob/master/docs/theming/Shape.md)
 |
Available
 |

## M3 Expressive update

**May 2025**

Added 35 **new shapes** and **shape morphing** to [Material Shape Library](https://www.figma.com/community/file/1035203688168086460) (Figma Design Kit) and [Jetpack Compose](https://developer.android.com/reference/kotlin/androidx/compose/material3/MaterialShapes).

Added new shape principles and a refreshed art direction.

Added corner radii tokens:

- Large increased (20dp)
- Extra large increased (32dp)
- Extra extra large (48dp)
- Updated fully rounded corners to use **full**. Previously, this was defined using 50% of the component size.

[More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

_footer: Overview of Material shapes_
_altText: Animation of available Material shapes._

## Shape library

_footer: M3 has 35 shapes to easily apply to designs_
_altText: 35 shapes in the shape set._

## Use shapes and text in harmony

Shapes are expressive elements of Material 3 that echo key visual attributes of [M3 typography](/m3/pages/typography/overview/). 

Use shape and type together for products to feel cohesive and polished.

_footer: M3 shapes and Google Sans Flex share roundness visual attributes_
_altText: Fonts and mock UI screens showing a wide range of square, round, thin, and thick shapes._

_footer: Shape morphing should respond to user interaction_
_altText: While a person taps water and squeezes a soft cube, a button in the middle responds similarly._

## Morph shapes to connect function and feeling

Shapes should morph to improve understanding and add moments of delight. Use shape morph to better communicate:

- Interaction states, like when a button is selected
- Actions in progress, like a friend typing, or a page loading
- Changes in the environment, like sound, temperature, or time of day

Think about how shapes could react to different interactions, such as tapping, swiping, scrolling, releasing, and long pressing.

## Be bold and dare to embrace tension

Tension happens when the shape story changes unexpectedly, such as when contrasting shapes are used. This can be created using both square and rounded shapes, unconventional shapes, and other contrasting elements.

Material historically focused on rounded shapes. However, using sharp shapes, thereby adding tension, creates more dynamic design, one that’s more memorable and expressive.

This tension can be used in many ways, like conveying states, drawing attention to an element, or to improve the visual aesthetic.

_footer: Create tension by using a combination of round and square shapes_
_altText: Round and square shape side-by-side._

_footer: Shapes and motion can communicate actions in progress_
_altText: Use different types of shape in loading indicators to show progress._

## Shape is versatile, not semantic

Avoid making shapes literal or assigning a specific function or meaning to a single shape.

For example, the loading indicator can be wavy, but the waveform is not a strict symbol of progression. Progress could just as easily be shown using rotating shapes or shape morph. 

Plus, waveforms could be used in other places unrelated to progress, like button containers.

## Use abstract shapes sparingly

Be intentional when using shapes in product UI. Don’t compromise clarity for the sake of visual design.

When incorporating diverse shapes, think about how they fit into the overall design and consider how they balance with the entire composition. Ensure that shapes resonate with the product's narrative. Consider the 'why' behind their inclusion and the value they contribute to the overall user experience.

_footer: Shapes without clear meaning behind why they’re different can add more visual clutter than delight_
_altText: 8 shapes with icons._

_footer: Essential shapes can use shape morph to communicate change_
_altText: Shapes morphing to indicate different states._

_footer: Use abstract shapes on imagery and decorative UI_
_altText: Shapes being applied as masks on photos to make them more interesting._

## Emphasize aesthetic moments with shape

Get creative when using shape in graphics, for photography cropping, personalized avatar masking, and other non-interactive elements.

Decorative moments offer the most flexible and creative uses of shape.

## Shape can be 2.5D

When effectively used, shape and motion can make 2D visuals feel 3D. They provide the illusion of depth and volume, making visuals more eye-catching and natural.

_footer: Apply motion and shape differently on each layer to give it the illusion of depth_
_altText: Shapes spinning and a weather icon transforming into the current temperature._

<!-- section: Corner radius scale -->

Material components use a corner radius scale to define all rectangular shapes, such as buttons, carousels, and dialogs.

_footer: M3 defines corner radii using a shape scale. This can be used to create both uniform and asymmetrical shapes._
_altText: Illustration of range of shapes._

## Shape tokens

Material has shape corner tokens to define all corners, and corner-value tokens for individual corners. [Learn more about design tokens](/m3/pages/design-tokens/overview)

### Corner radius scale

The Material 3 shape system uses a size-based scale with ten styles. Styles are assigned to components based on the desired amount of roundedness. 

- None - 0dp
- Extra small - 4dp
- Small - 8dp
- Medium - 12dp
- Large - 16dp
- Large increased - 20dp
- Extra large - 28dp
- Extra large increased - 32dp
- Extra extra large - 48dp
- Full - fully rounded corners

[Apply shape styles using tokens](/m3/pages/design-tokens/overview)

_footer: Steps on the scale are named for the amount of roundedness applied to the corner_
_altText: 10 corner radii styles._

_footer: M2: Three-level shape scale based on the size of the component container_
_altText: Components illustrating the old 3-level shape scale._

_footer: M3: Ten-level shape scale based on the roundedness of shape corners_
_altText: Components illustrating the new 10-level shape scale._

## Symmetry

Components can have either symmetric or asymmetric corner shapes. Symmetric shapes have the same values for all corners, while asymmetric shapes can have corners with different values.

Both symmetric and asymmetric shapes use the same 10-step scale.

Asymmetrical shapes are used in M3 components with closely-grouped items, such as menus and split buttons. These are called **inner corners**.

_footer: **Inner corner**component tokens always map to individual corner shape tokens_
_altText: 3 shapes illustrating symmetrical and asymmetrical styles._

## Customizing shapes

Generally, products should consistently use the Material 3 shape styles. However, customization is sometimes necessary, and even encouraged, for hero moments or custom components. Shapes can be customized at the **style** or **component** level.

### Style changes

The corner radius shape style, like **medium**, can be customized to be a different size.

This applies the change to all components mapped to that shape style, unless they have an override.

_footer: Customizing the corner size of the **medium** style applies the change to all components using this style, such as cards and small FABs_
_altText: Shapes with different corner radii._

### Component changes

The style of a specific component, such as a button, can be changed by customizing which corner radius shape style it maps to.

For example, by default, buttons are mapped to the **full** corner radius shape style. If your product needs a less rounded shape, remap the token to another style in the shape scale, such as **small** or **medium**.

_footer: Remapping the shape for a component to a different style applies the change to just that component across the UI_
_altText: Components with different corner radii._

The shape style family can be customized from **rounded** to **cut**. This makes the corner a straight line instead of curved.  

Add extra padding to avoid cutting off content in information-dense components.   

For example, a large cut corner on a card will clip content and images in the area more than a rounded corner of the same size.

_footer: Be careful not to apply large or full corners to information-dense components, such as cards_
_altText: Card with text and full corners._

_footer: Shapes can be intentionally rounder to add more visual variety_
_altText: Carousel with images with rounded corners._

_footer: Add unexpected moments by switching between square and fully rounded shapes_
_altText: Carousel with full rounded shapes._

### Adjust for optical roundness

When nesting rounded objects, avoid using the same corner radii for both objects. This can make the corners look unbalanced.

Instead, adjust the corner radii to be proportional to each other; this is called optical roundness. To calculate optical roundness:

- Outer radius - padding = inner radius
- For example: 48dp - 14dp = 34dp

_footer: - Padding - Outer radius - Inner radius_
_altText: 3 parts of corner radii to adjust._

_footer: Use different corner radii values for nested components so they have optical roundness_
_altText: Nested carousel with optical roundness._

_footer: Avoid using the same corner radius value for nested objects_
_altText: Nested radii with the same roundness as its container._

### Using the shape library

The Material 3 shape library can be used to create more interesting containers. Use the shape library for mostly visual elements. Avoid applying unconventional shapes to text-heavy containers. 

Shapes should be used sparingly to provide a stronger emphasis and moments of delight.

_footer: Leverage the Material shape library for moments of delight_
_altText: Unexpected shapes in carousel._

<!-- section: Shape morph -->

The Material shape library supports easy transitioning, or morphing, between shapes. Shape morph is leveraged in the standard button group and loading indicator components.

## Using shape morph

Access to the Material shape library and the shape morph functionality are available through a platform-specific API.

- For Android, use the [Shapes in Compose API](https://developer.android.com/reference/kotlin/androidx/compose/material3/MaterialShapes)
- Web is not currently available

Shape morphing uses the expressive motion scheme by default. This can be switched to the standard motion scheme as needed.

_footer: The Material shape library contains many types of shapes that can all morph seamlessly into each other_
_altText: Shapes available in the shape morph API library._

Material uses shape morphing in the standard button group and loading indicator components.

_footer: The standard button group uses shape morph to show interaction_
_altText: Morphing buttons react to user clicking._

_footer: The loading indicator uses shape morph to show progress_
_altText: Loading indicator with shape morph._
