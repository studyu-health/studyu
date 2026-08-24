# Material 3 · Motion

<!-- Source: m3.material.io · styles_motion_overview · updated 2026-07-17T05:25:55.367Z · CC-BY 4.0 (Google) -->

## Motion physics system

> The motion physics system makes a UI expressive and easy to use



<!-- section: How it works -->

_altText: Showcase of expressive components and motion curves._

## A motion system designed for expression

**May 2025**

Material introduced the **motion physics system** with M3 Expressive. This new physics-based system makes interactions and transitions feel more alive, fluid, and natural. It represents a new motion language for Google products, and is easier to implement and customize than ever before. 

The physics system is replacing the previous system based on [easing and duration](/m3/pages/motion-easing-and-duration/applying-easing-and-duration/).

[More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

## Availability & resources

**Type**
 |
**Link**
 |
**Status**
 |

Implementation
 |
[Android Views (MDC-Android)](https://github.com/material-components/material-components-android/blob/master/docs/theming/Motion.md)
 |
Available. Not added to components. [See specs](https://m3.material.io/styles/motion/overview/specs)

 |

Flutter
 |
Unavailable
 |

[Jetpack Compose](https://developer.android.com/reference/kotlin/androidx/compose/material3/MotionScheme)
 |
Available
 |

Web
 |
Compatible with Compose springs. [See specs](https://m3.material.io/styles/motion/overview/specs)

 |

## The basics: Motion schemes

The physics system has two preset motion schemes: **expressive** and **standard**. The motion scheme you choose defines how your product feels. While most motion in a product should use the same scheme, products can make [advanced customizations](/m3/pages/motion-overview/how-it-works#fef83d57-b139-4c40-b538-9f1e9872df1b) to swap the scheme to emphasize key moments.

**Expressive** is Material’s opinionated motion scheme, and should be used for most situations, particularly hero moments and key interactions.

_footer: The expressive motion scheme overshoots the final values to add bounce_
_altText: A circle moves across the screen with expressive motion. It has a trail showing the level of bounce applied._

**Standard** feels more functional with minimal bounce, and should be used for utilitarian products.

_footer: The standard motion scheme eases into the final values_
_altText: A circle moves across the screen with standard motion. It has a trail showing the lack of bounce applied._

Need something other than the preset schemes? [Create your own!](/m3/pages/motion-overview/how-it-works#f4ec8b84-3e39-4699-bba3-0fe7ec5cb79e) The physics system makes it easy to create custom motion schemes beyond expressive and standard, while still leveraging theming. Schemes can be easily switched between expressive, standard, or custom as needed.

## How it works: Springs

Motion schemes use **springs**. A spring is a combination of three attributes which control all motion behavior: stiffness, damping, and initial velocity.

**Springs are versatile**. One spring can apply to many situations, such as transitions, button effects, or gestures. This makes the motion and expression feel consistent throughout the product.

**Springs feel natural**. Springs are designed to be predictable, like how objects move and bounce. They handle gestures, interruptions, and retargeting animations seamlessly.

_footer: All component motion is driven by two tokens: expressive fast spatial and expressive fast effects_
_altText: Buttons, FAB menus, and toolbars moving with expressive motion springs._

## Spring tokens

On Jetpack Compose and Android Views (MDC-Android), these springs are available as [spring tokens](/m3/pages/motion-overview/specs/)**.** Use tokens to easily apply motion to any element, making all motion feel predictable and consistent across multiple platforms. See [specs](/m3/pages/motion-overview/specs) for how to convert springs to other platforms like Web.

There are tokens for **spatial** movement and **effects**, with three durations each: **default**, **fast**, and **slow**.

For example, to apply fast, spatial, expressive motion, call the "expressive" motion scheme, then use the token: md.sys.motion.spring.fast.spatial.

Notice that the "expressive" scheme isn't part of the token itself. Rather, it's called at the product level and applied to all tokens. This makes it easier to swap schemes without changing assigned tokens.

_footer: Each scheme (expressive, standard) has three speeds (fast, default, slow) for two types of movement (spatial, effects)_
_altText: A chart of the token structure. A scheme has 3 speeds. Each speed has a spatial token and an effects token._

### Style

**Spatial** spring tokens are used for animations that move something on screen, for example the x and y position, rotation, size, rounded corners. This spring overshoots the final value and bounces into place.

_footer: Spatial springs apply to movement_
_altText: A moving shape bounces into place._

_footer: Spatial springs apply to rotation_
_altText: A spinning shape bounces into place._

**Effects** spring tokens are used to animate properties such as color and opacity animations, where there shouldn’t be any overshoot.

_footer: Effects springs applied to opacity_
_altText: A shape fades in and eases into view._

_footer: Effects springs applied to color_
_altText: A shape changes color and eases into the final result._

### Speed

Spatial and effect spring tokens come in three speeds: **default**, **fast**, and **slow**. Most motion should use the default speed, while smaller elements may use fast and larger elements may use slow.

Speed
 | Spatial example
 | Effects example
 |
Default
 | Animations that partially cover the screen, such as bottom sheet and expanded navigation rail | Opacity of the content within a navigation rail |
Fast
 | Small components, such as switches and buttons | Color change of the switch handle |
Slow
 | Full-screen animations | Full-screen content refresh |

_footer: Spatial motion in fast, default, and slow speeds_
_altText: Effects motion in fast, default, and slow speeds_

_footer: Effects motion in fast, default, and slow speeds_
_altText: Spatial motion in fast, default, and slow speeds_

Spring tokens work across devices. For example, the spatial fast token will always be faster than default or slow, but the exact values of each token differ depending on if the device is a wearable, phone, or tablet. This ensures the movement feels fast in the context of the device.

## Application

### Components

On Jetpack Compose, 21 Material components use the motion physics system by default. Android Views (MDC-Android) support is coming soon. To add the motion physics system to other components, including custom-built components, use spring tokens. [View full specs](/m3/pages/motion-overview/specs)

_footer: Material components use the physics motion system to feel more expressive_
_altText: A collection of expressive components in motion._

## Advanced customizations

There are a few different levels for applying motion. Choose the level that applies best to your product or specific component.

### Level 1: Use a default motion scheme

The expressive and standard schemes should be sufficient for all motion needs. On Jetpack Compose, components use these schemes by default.

_footer: Switch using the expressive motion scheme_
_altText: Switch using the expressive motion scheme._

_footer: Switch using the standard motion scheme_
_altText: Switch using the standard motion scheme._

### Level 2: Create a custom motion scheme

On Jetpack Compose, to change the default motion scheme that all components and transitions use, create a custom MotionScheme object, and return different AnimationSpec for each property of the motion scheme.

_footer: FAB menu with an extra stiff custom scheme_
_altText: FAB menu with an extra stiff custom scheme._

_footer: FAB menu with very low stiffness custom scheme_
_altText: FAB menu with a minimally stiff custom scheme._

### Level 3: Swap the default motion scheme per element

Why use just one scheme when you can use multiple? On Jetpack Compose, to use one scheme for most of the product, such as **expressive**, but on certain elements swap it for another scheme, like **standard**, override the CompositionLocal for that particular composable, screen, or element.

<!-- section: Specs -->

## Cross-platform experiences

The motion physics system is available on Jetpack Compose and Android Views (MDC-Android), and can be easily adapted to other platforms.

Platform
 |
Status
 |
How to apply
 |

Jetpack Compose
 |
Available
 |
Use built-in components and spring tokens.
 |

Android Views (MDC-Android)
 |
Available. Not  added to components.
 |
Use built-in spring tokens.
 |

Web
 |
Compatible
 |
Use springs when possible, otherwise use curves that mimic the springs for animations without interruptions or gestures. [View web conversion table](/m3/pages/motion-overview/specs#e3e4f10b-6314-47b7-9051-988066081fa0)

 |

## Tokens and specs

The **spring composite**tokens are used in the motion physics system. These composites combine two **spring** tokens (damping and stiffness) into a single token for ease of use. The **easing**, **duration**, and **path** tokens are used by the legacy system, so can be ignored.

## Web: Convert springs to curves

Spring
 | Curve
 |
Expressive fast spatial | 0.42, 1.67, 0.21, 0.90. Duration =  350ms |
Expressive default spatial | 0.38, 1.21, 0.22, 1.00. Duration =  500ms |
Expressive slow spatial | 0.39, 1.29, 0.35, 0.98. Duration =  650ms |
Expressive fast effects | 0.31, 0.94, 0.34, 1.00. Duration =  150ms |
Expressive default effects | 0.34, 0.80, 0.34, 1.00. Duration =  200ms |
Expressive slow effects | 0.34, 0.88, 0.34, 1.00. Duration =  300ms |
Standard fast spatial | 0.27, 1.06, 0.18, 1.00. Duration =  350ms |
Standard default spatial | 0.27, 1.06, 0.18, 1.00. Duration =  500ms |
Standard slow spatial | 0.27, 1.06, 0.18, 1.00. Duration =  750ms |
Standard fast effects | 0.31, 0.94, 0.34, 1.00. Duration =  150ms |
Standard default effects | 0.34, 0.80, 0.34, 1.00. Duration =  200ms |
Standard slow effects | 0.34, 0.88, 0.34, 1.00. Duration =  300ms |

## Easing and duration

The original easing and duration tokens are still available to use as a fallback, and are currently used for animating transitions. [View easing and duration system](/m3/pages/motion-easing-and-duration/applying-easing-and-duration)

---

<!-- Source: m3.material.io · styles_motion_easing-and-duration · updated 2026-07-17T05:03:58.337Z · CC-BY 4.0 (Google) -->

## Easing and duration

> Easing and duration create responsive and expressive motion



<!-- section: Applying easing and duration -->

starNote:In the expressive update, components and motion now use the [motion physics system](/m3/pages/motion-overview/), which uses springs. Products should migrate to the new system. The easing and duration system is still used for transitions and can be used by teams that haven't yet updated to GM3 Expressive, but is no longer maintained.

## Suggested easing and duration pairs

Choosing the right combination of easing and duration can be complicated. As a simple starting point, these are sensible defaults that will work for most transitions.

**Easing**  | **Duration** | **Transition type** |
Emphasized | 500ms | Begin and end on screen |
Emphasized decelerate | 400ms | Enter the screen |
Emphasized accelerate | 200ms | Exit the screen |
Standard | 300ms | Begin and end on screen |
Standard decelerate | 250ms | Enter the screen |
Standard accelerate
 | 200ms | Exit the screen |

## Easing

In the physical world, objects don’t start or stop instantaneously. Instead, they take time to speed up and slow down. Transitions without easing look stiff and mechanical, while a transition with easing appears more natural.

_footer: - A transition with easing - A transition without easing_
_altText: Motion curve with and without easing._

Compared to the utilitarian style of M2, M3 easing is more expressive. Transitions have snappy take offs and very soft landings. 

Durations are slightly longer compared to M2. This gives transitions time to come to a gentle rest without feeling abrupt.

_footer: - M2 easing and duration - M3 easing and duration_
_altText: Comparison of M2 and M3 easing curves._

### Choosing an easing set

The [**Emphasized easing set**](/m3/pages/motion-easing-and-duration/tokens-specs#cbea5c6e-7b0d-47a0-98c3-767080a38d95) is recommended for most transitions to capture the style of M3.

The [**Standard easing set**](/m3/pages/motion-easing-and-duration/tokens-specs#601d5552-a6e6-4d74-9886-ff8f24b9ec35) can be used for small utility focused transitions that need to be quick. The Standard set is also a fallback for platforms that don't support Emphasized easing, like iOS and Web.

_footer: Emphasized easing is used for this full screen transition_
_altText: Expanding card in a note taking app._

_footer: Standard easing is used for this Text field transition on Web. The simple style fits the utility of this component._
_altText: Text field selection in an email app._

### Choosing an easing type

Easing types are chosen based on how a transition moves in relation to the screen.

#### Begin and end on screen

These transitions use Emphasized easing. It speeds up quickly and then comes to a gentle rest in order to emphasize the end of the transition.

_footer: This transition begins and ends on screen so it uses Emphasized easing_
_altText: Card expanding in a podcast app._

#### Enter the screen

These transitions use Emphasized decelerate easing. It begins at peak velocity then comes to a gentle rest.

#### Exit the screen permanently

These transitions use Emphasized accelerate easing. It begins at rest and ends at peak velocity. By ending at peak velocity, it gives the impression the exiting component cannot be retrieved.

_footer: This Bottom sheet enters with Emphasized decelerate and exits permanently with Emphasized accelerate_
_altText: Card rising from bottom of screen, then retreating quickly back to bottom of screen after being exited._

#### Exit the screen temporarily

These transitions use **Emphasized** easing. By ending at rest just off screen, it gives the impression the exiting component can be retrieved.

_footer: This drawer enters and exits temporarily with Emphasized easing_
_altText: Calendar menu is temporarily collapsed to the left._

## Duration

Transitions shouldn’t be jarringly fast or so slow that users feel as though they’re waiting. The right combination of duration and easing produces smooth and responsive transitions.

_footer: A transition with a well tuned duration is quick and easy to follow_
_altText: Clock icon is expanded to smoothly take over the screen._

_footer: Avoid transitions with such a short duration they become jarring_
_altText: Clock icon is expanded rapidly, in abrupt fashion, to take over the screen._

### Choosing a duration

Durations are chosen based on these criteria:

#### Transition size

Transitions that cover small areas of the screen have short durations. Those that traverse large areas have long durations. Scaling duration with the size of a transition area gives a consistent sense of speed.

_footer: This transition covers a small area with a short 200ms duration_
_altText: A series of radio buttons are selected on the Settings screen._

_footer: This transition covers a large area with a long 500ms duration_
_altText: An album is selected that takes over the screen._

#### Enter vs. exit transitions

Transitions that exit, dismiss, or collapse an element use shorter durations. Exit transitions are faster because they require less attention than the user’s next task.

Transitions that enter or remain persistent on the screen use longer durations. This helps users focus attention on what's new on screen.

_footer: - An Enter transition has a long duration of 500ms - An Exit transition has a short duration of 200ms_
_altText: Pop up screen on an email draft has option to delete or cancel._

_footer: - An Enter transition has a long duration of 500ms - An Exit transition has a short duration of 200ms_
_altText: Bottom sheet uses a longer animation duration to enter and a shorter duration to exit the screen._

<!-- section: Tokens & specs -->

starNote:In the expressive update, components and motion now use the [motion physics system](/m3/pages/motion-overview/), which uses springs. Products should migrate to the new system. The easing and duration system is still used for transitions and can be used by teams that haven't yet updated to GM3 Expressive, but is no longer maintained.

## Tokens

Motion easing and duration can be implemented using easing and duration tokens. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Easing

### Emphasized easing set

This set is the most common because it captures the expressive style of M3.

_footer: Emphasized_
_altText: A line graph illustrating an emphasized easing pattern._

_footer: Emphasized decelerate_
_altText: A line graph illustrating an emphasized decelerate easing pattern._

_footer: Emphasized accelerate_
_altText: A line graph illustrating an emphasized accelerate easing pattern._

Info/Platform | Emphasized | Emphasized decelerate
 | Emphasized accelerate
 |
Token | md.sys.motion.easing.emphasized | md.sys.motion.easing.emphasized.decelerate | md.sys.motion.easing.emphasized.accelerate |
Android | [pathInterpolator(M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0.05f, 0.7f, 0.1f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0.3f, 0f, 0.8f, 0.15f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) |
CSS | N/A (Use Standard as a fallback) | [cubic-bezier(0.05, 0.7, 0.1, 1.0)](https://www.w3schools.com/cssref/func_cubic-bezier.asp) | [cubic-bezier(0.3, 0.0, 0.8, 0.15)](https://www.w3schools.com/cssref/func_cubic-bezier.asp) |
Flutter | [easeInOutCubicEmphasized](https://api.flutter.dev/flutter/animation/Curves/easeInOutCubicEmphasized-constant.html) | [Cubic(0.05, 0.7, 0.1, 1.0);](https://api.flutter.dev/flutter/animation/Cubic-class.html) | [Cubic(0.3, 0.0, 0.8, 0.15);](https://api.flutter.dev/flutter/animation/Cubic-class.html) |
iOS | N/A (Use Standard as a fallback) | [ControlPoints:0.05f:0.7f:0.1f:1.0f];](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) | [ControlPoints:0.3f:0.0f:0.8f:0.15f];](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) |
After Effects | Use [After Effects Easing Panel](https://storage.googleapis.com/material-io-static/resources/material-easing-1.1.3.zxp) (download) |

### Standard easing set

This set is used for simple, small, or utility-focused transitions.

_footer: Standard_
_altText: A line graph illustrating a standard easing pattern._

_footer: Standard decelerate_
_altText: A line graph illustrating a standard decelerate easing pattern._

_footer: Standard accelerate_
_altText: A line graph illustrating a standard accelerate easing pattern._

| Standard | Standard decelerate | Standard accelerate |
Token | md.sys.motion.easing.standard | md.sys.motion.easing.standard.decelerate | md.sys.motion.easing.standard.accelerate |
Android | [PathInterpolator(0.2f, 0f, 0f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0f, 0f, 0f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0.3f, 0f, 1f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) |
CSS | [cubic-bezier(0.2, 0.0, 0, 1.0);](https://www.w3schools.com/cssref/func_cubic-bezier.asp) | [cubic-bezier(0, 0, 0, 1);](https://www.w3schools.com/cssref/func_cubic-bezier.asp) | [cubic-bezier(0.3, 0, 1, 1);](https://www.w3schools.com/cssref/func_cubic-bezier.asp) |
Flutter | [Cubic(0.2, 0.0, 0, 1.0);](https://api.flutter.dev/flutter/animation/Cubic-class.html) | [Cubic(0, 0, 0, 1);](https://api.flutter.dev/flutter/animation/Cubic-class.html) | [Cubic(0.3, 0, 1, 1);](https://api.flutter.dev/flutter/animation/Cubic-class.html) |
iOS | [ControlPoints:0.2f:0.0f:0.0f:1.0f](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) | [ControlPoints:0.0f:0.0f:0.0f:1.0f](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) | [ControlPoints:0.3f:0.0f:1.0f:1.0f];](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) |
After Effects | Use [After Effects Easing Panel](https://storage.googleapis.com/material-io-static/resources/material-easing-1.1.3.zxp) (download) |

## Duration

### Short durations

These are used for small utility-focused transitions.

**Token** | **Value** |
md.sys.motion.duration.short1 | 50ms |
md.sys.motion.duration.short2 | 100ms |
md.sys.motion.duration.short3 | 150ms |
md.sys.motion.duration.short4 | 200ms |

_footer: Selection controls have a short duration of 200ms with Standard easing_
_altText: Animation showing a 200ms duration and standard easing curve applied to selection control interactions._

### Medium durations

These are used for transitions that traverse a medium area of the screen.

**Token** | **Value** |
md.sys.motion.duration.medium1 | 250ms |
md.sys.motion.duration.medium2 | 300ms |
md.sys.motion.duration.medium3 | 350ms |
md.sys.motion.duration.medium4 | 400ms |

_footer: A FAB expanding into a Sheet uses a 400ms duration with Emphasized easing_
_altText: Animation showing a FAB expanding into a sheet with a 400ms duration and Emphasized easing._

### Long durations

These durations are often paired with Emphasized easing. They're used for large expressive transitions.

**Token** | **Value** |
md.sys.motion.duration.long1 | 450ms |
md.sys.motion.duration.long2 | 500ms |
md.sys.motion.duration.long3 | 550ms |
md.sys.motion.duration.long4 | 600ms |

_footer: A Card expanding to full screen uses a long 500ms duration with Emphasized easing_
_altText: Animation showing a card expanding into a full screen with a 500ms duration and emphasized easing._

### Extra long durations

Though rare, some transitions use durations above 600ms. These are usually used for ambient transitions that don't involve user input.

**Token** | **Value** |
md.sys.motion.duration.extra-long1 | 700ms |
md.sys.motion.duration.extra-long2 | 800ms |
md.sys.motion.duration.extra-long3 | 900ms |
md.sys.motion.duration.extra-long4 | 1000ms |

_footer: An ambient carousel auto-advance transition uses an extra long 1000ms duration with emphasized easing_
_altText: Animation showing the transition of an ambient carousel auto-advancing with a 1000ms duration and emphasized easing._

---

<!-- Source: m3.material.io · styles_motion_transitions · updated 2026-07-17T05:34:42.925Z · CC-BY 4.0 (Google) -->

## Transitions

> Transitions help guide people as they navigate an app



<!-- section: Transition patterns -->

starNote:M3 transitions use the legacy easing and duration system. They'll eventually be updated to use the motion physics system.

Transitions are short animations that connect individual elements or full-screen views of an app. They are fundamental to a great user experience because they help users understand how an app works. Well-designed transitions makes an experience feel high quality and expressive. They should be the top priority for a strong motion implementation. 

These are six common transition patterns:

- [Container transform](/m3/pages/motion-transitions/transition-patterns#b67cba74-6240-4663-a423-d537b6d21187)
- [Forward and backward](/m3/pages/motion-transitions/transition-patterns#df9c7d76-1454-47f3-ad1c-268a31f58bad)
- [Lateral](/m3/pages/motion-transitions/transition-patterns#8d4ec98f-60dc-47a9-901e-88fa2c43f18a)
- [Top level](/m3/pages/motion-transitions/transition-patterns#f852afd2-396f-49fd-a265-5f6d96680e16)
- [Enter and exit](/m3/pages/motion-transitions/transition-patterns#e1c2a650-d7a4-4a6d-9025-e6b7845291ed)
- [Skeleton loaders](/m3/pages/motion-transitions/transition-patterns#b39a0641-1b44-4864-83f5-fac38e0bd94a)

_altText: Small, colorful blobs are animated with different motion styles corresponding to the six transition patterns._

## Container transform

This pattern is used to seamlessly transform an element to show more detail, like a Card expanding into a details page.

-
**Commonly used with:** Cards, lists, image galleries, search boxes, sheets, FABs, and chips

-
**Read more:** [UX Research](https://material.io/blog/motion-research-container-transform), [Guidelines](/m3/pages/motion-transitions/applying-transitions#50f9fc3f-c7e2-4099-b614-7c36b1c5285d), [Android implementation](https://github.com/material-components/material-components-android/blob/master/docs/theming/Motion.md#container-transform)

Persistent elements are used to seamlessly connect the start and end state of the transition. The most common persistent element is a container, which is a shape used to represent an enclosed area. It can also be an important element, like a hero image. Of all transition patterns, this one creates the strongest relationship between elements. It's also perceived to be the most expressive.

_footer: A container transform is used when opening an app and a card. This makes the relationship between screens clear and gives an expressive quality to the transition._
_altText: Podcast app is selected from home screen, then individual card is selected, both taking over the screen._

#### Between full-screen views

_footer: A container transform is used to expand this image to a fullscreen view_
_altText: 1-year memory of flowers is selected within a carousel and takes over screen._

_footer: A container transform is used to expand this List item to a fullscreen view_
_altText: Individual message is selected in messaging app and expands to view complete message._

_footer: A container transform is used to expand this Card and Search box to a fullscreen view_
_altText: Grocery list is selected within notes and expands to take over screen._

#### Within a screen

_footer: A container transform is used to expand this search box_
_altText: Search box for replies within messaging app expands to reveal recent searches and contacts._

_footer: This container transform FAB transition has a persistent container and icon_
_altText: FAB is selected and expands to reveal  Compose Now action and shortlist of contacts._

_footer: A container transform is used on an expanding Sheet_
_altText: Song is selected from banner on bottom of screen and expands to take over._

## Forward and backward

This pattern is used for navigating between screens at consecutive levels of hierarchy, like navigating from an inbox to a message thread.

- **Commonly used with**: Lists, cards, buttons, links
- **Read more:** [Guidelines](/m3/pages/motion-transitions/applying-transitions#41b11a78-b88f-4972-904c-880bc348acc8), [Android implementation](https://github.com/material-components/material-components-android/blob/master/docs/theming/Motion.md#shared-axis)

A horizontal sliding motion indicates moving forward or backward between screens. Android and iOS have different default styles:

**1. Android** uses a fade as screens slide. This reduces the amount of motion, since the screens don't have to slide the full width of the device.

**2.****iOS** uses a parallax effect, meaning the background slides slower than the foreground. This also reduces the amount of motion.

_footer: - Android’s default forward and backward transition - iOS’ default forward and backward transition_
_altText: Two motions contrasted in messaging app, with top showing Android’s fading movement and bottom showing iOS’s swiftly moving foreground transition._

_footer: A filled button on Android uses a forward and backward transition_
_altText: WiFi set-up screen demonstrates Android fade effect when next button is selected._

_footer: A card on iOS uses a forward and backward transition_
_altText: Music card uses iOS transition to move back to music app._

_footer: A search icon button in Android uses a forward and backward transition_
_altText: Fading transitions between photos app search bar and selection of Family & friends option._

_footer: Tapping a list item on a tablet uses a forward and backward transition_
_altText: Email is selected from inbox demonstrating Android transition._

## Lateral

This pattern is used for navigating between peer content at the same level of hierarchy, like swiping between tabs of a content library.

- **Commonly used with:**Tabs, carousels, and image galleries
- **Read more:** [Guidelines](/m3/pages/motion-transitions/applying-transitions#3d5c16ce-7350-4a33-9d2b-598a7591d4e6)

Lateral transitions use a sliding motion similar to a forward and backward pattern, but it does not use a fade or parallax effect. Instead elements are grouped and slide in unison, creating a strong peer relationship. This also hints at being able to gesturally swipe elements to navigate.

_footer: A lateral transition is used when tapping or swiping a Tab component_
_altText: Toggling between tabs for artists and albums in music app reveals lateral movement._

_footer: A lateral transition is used when swiping through a photo album_
_altText: Photos are swiped through horizontally, each filling the screen._

_footer: A lateral transition used with a Carousel component_
_altText: Carousel is scrolled through horizontally without use of fades._

## Top level

This pattern is used to navigate between top-level destinations of an app, like tapping a destination in a Navigation bar.

- **Commonly used with:** Navigation bar, navigation rail, and navigation drawer
- **Read more:** [Guidelines](/m3/pages/motion-transitions/applying-transitions#ab8885f6-5517-419d-80de-bea50cd10467), [Android implementation](https://github.com/material-components/material-components-android/blob/master/docs/theming/Motion.md#fade-through)

The exiting screen quickly fades out and then the entering screen fades in. Since the content of top level destinations isn't necessarily related, the motion intentionally does not use grouping or persistent elements to create a strong relationship between screens.

_footer: A navigation bar uses a top level transition_
_altText: Home and Music options in the navigation are toggled between with fading indicating distinctness of items._

_footer: Tapping an item in a navigation drawer uses a top level transition to move between destinations_
_altText: Inbox menu item selected fades to reveal inbox contents._

_footer: A navigation rail uses a top level transition_
_altText: Chat and Mail options in navigation both produce swift transitions._

## Enter and exit

This pattern is used to introduce or remove a component on the screen. Components can enter and exit within the screen bounds, like a dialog appearing over an app. They can also enter and exit by crossing the screen bounds, like a navigation drawer or bottom sheet that slides on and off screen.

### Within screen bounds

- **Commonly used with:** FABs, dialogs, menus, snackbars, time pickers and tooltips
- Read more: [Guidelines](/m3/pages/motion-transitions/applying-transitions#56675bd6-5e69-4fa8-b075-d694e8cb3ad4)

**Android** components expand and collapse along the x or y axis as they enter and exit. Scale and z-axis motion is avoided since they imply elevation change, which doesn't match M3's reduced elevation model.

**iOS** components uniformly scale as they enter and fade out to exit.

_footer: - Android enter and exit transitions - iOS enter and exit transitions_
_altText: Message to permanently delete an email pops up without elevation for both Android and iOS._

The direction a component enters is informed by their location on screen, expanding away from the device edge. A menu at the top of the screen expands downwards, and a snackbar at the bottom of the screen expands upwards.

_footer: A menu at the top of the screen expands downwards as it enters_
_altText: Image menu in upper right corner expands downward._

_footer: A snackbar and FAB use an enter and exit transition_
_altText: A snackbar alert pops up from bottom of inbox screen and FAB emerges from lower right._

### Beyond screen bounds

- **Commonly used with:**App bars, banners, navigation bar, navigation rail, navigation drawer, and sheets
- **Read more:** [Guidelines](/m3/pages/motion-transitions/applying-transitions#1b704202-167d-48d5-bca1-614cf050de1b)

**Android** components expand and collapse along the x or y axis as they slide on and off screen. This emphasizes their shape, making an otherwise simple transition more expressive.

**iOS** components slide on and off screen without changing shape.

_footer: - Android enter and exit transitions - iOS enter and exit transitions_
_altText: Android and iOS demonstrations of navigation emerging from left edge and new message alert emerging from top edge._

Components like a side sheet can also enter and exit at the same elevation as the main content. Coplanar sheets shrink the available area for content.

_footer: A coplanar side sheet uses an enter and exit transition_
_altText: Selection of comments icon shrinks the main draft field._

Components can enter and exit from beyond the screen bounds based on a scroll gesture. This allows for more screen space to browse.

_footer: A top app bar slides off and on screen during a scroll_
_altText: Top Stories header disappears as user scrolls deeper into news._

_footer: A navigation bar slides off and on screen during a scroll_
_altText: Scrolling lower through photos hides navigation, saving room for browsing._

The location components enter and exit help establish a coherent spatial model of an app:

- A **notification** enters from the top indicating the notification drawer can also be pulled down from the top
- A **nav drawer** enters from the left helping users understand where it's located when it's off screen
- A **bottom sheet** and the keyboard enters from the bottom of the screen. This is a sensible default location for sheets to enter since the bottom of the screen is easiest to reach.

_footer: The direction of enter and exit transitions help establish a coherent spatial model_
_altText: Email notification emerges from top of screen, navigation emerges from left, and keyboard enter from below, all in sequence._

## Skeleton loaders

This pattern is used to transition from a temporary loading state to a fully loaded UI.

-
**Read more**: [Guidelines](/m3/pages/motion-transitions/applying-transitions#b82b5150-609b-4540-903b-2b900ef830aa)

Skeleton loaders are UI abstractions that hint at where content will appear once it's loaded. They're used in combination with other transitions to reduce perceived latency and stabilize layouts as content loads.

_footer: A skeleton loader is used after an app launches to indicate content is loading_
_altText: Music app is selected, producing a skeleton soon populated by individual music items in each corresponding outline._

Skeleton loaders have a subtle pulsing animation to indicate indeterminate progress. It starts at the top left of the screen and moves down to the bottom right.

Once content is loaded, it quickly fades in on top of the skeleton loader.

_footer: A pulsing animation indicates indeterminant loading_

_footer: Content quickly fades in once it's loaded_

<!-- section: Applying transitions -->

starNote:M3 transitions use the legacy easing and duration system. They'll eventually be updated to use the motion physics system.

## What makes a good transition?

Well-designed transitions should have these characteristics:

### Follows accessibility settings

Most platforms have a reduced animation setting to help users with a sensitivity to motion. If that setting is on, transitions should:

- Use subtle fades instead of intense sliding or scaling animations
- Disable decorative effects like parallax or shape morphing

_footer: - Transitions with a default motion setting - Transitions with a reduced motion setting turned on_
_altText: Podcast is selected and exited quickly on the left, while a podcast is selected and exited more slowly on the right._

### Consistent

Consistently applying the right type of transition helps make apps feel cohesive and predictable to use.

_footer: These four Android apps use the same forward and backward transition, making them feel like a cohesive family of apps_
_altText: Multiple apps move in tandem with the same motion effect, appearing in sync._

### Stable layouts

Use skeleton loaders so that UI elements are coherent and stable during a transition. Avoid content shifting positions or instantly popping in as it loads. It can be distracting and frustrating to use.

_footer: Transitions should use skeleton loaders with a subtle pulsing animation to stabilize a layout as it loads_
_altText: Podcast window opens with pulsing outline that frames content added slowly._

_footer: Content should not pop in and shift locations during a transition_
_altText: Podcast window opens with no outline, and content added into haphazard clusters._

### No jarring jump cuts

Jump cuts should generally be avoided as a default setting since they can be disorienting. Instantly transitioning from one screen to the next offers no clues to help a user orient themselves.

If pure efficiency is a top priority, like opening a menu in a productivity app, a jump cut may be preferred.

_footer: Animated transitions help users orient themselves as they navigate_
_altText: Items in a music library are smoothly transitioned between._

_footer: For most common transitions, jump cuts are jarring and disorienting_
_altText: Items in a library are selected with stark, quick transitions._

### Coherent spatial model

Transitions are used to establish a coherent spatial model. This helps users understand the physical layout of an app.

_footer: These carousel transitions have a coherent spatial layout while navigating between a collapsed and expanded view_
_altText: An image within a horizontal carousel is also scrolled horizontally._

_footer: Switching between horizontal and vertical carousel layouts creates a confusing spatial model_
_altText: An image within a horizontal carousel is scrolled vertically._

### Unified direction

A transition should have a unified direction of movement. Elements are grouped and move along a primary axis instead of moving in independent directions. Only important elements like hero images remain persistent throughout the transition. This helps guide a users focus.

_footer: This transition has a simple vertical motion that’s easy to follow_
_altText: Selected song expands in a cohesive upward direction, marked by two blue lines showing unified movement._

_footer: Don’t animate many persistent elements independently. The various moving parts are distracting_
_altText: Selected song expands in a jarring manner with multiple elements moving in different directions, marked by multiple red lines._

### Clean fades

Fully fade out content before fading new content in. This avoids the overlap of partially transparent elements resulting in distracting and messy frames.

If a cross fade needs to occur, keep it quick and hide it during the fastest part of the transition.

_footer: Fade content out before fading new content in to maintain a clean design_
_altText: Selected restaurant information fades out as it shrinks to reveal Google Map beneath.._

_footer: Avoid showing cross faded content, the overlap of partially transparent elements can result in messy and distracting frames_
_altText: Restaurant information remains visible as it shrinks and reveals the map beneath._

Don't slowly fade components on top of other content as they enter or exit. This creates distracting cross faded frames. If a fade is needed, like with a Dialog entering in the middle of the screen, the fade should use a short duration to hide that part of the transition.

_footer: Don't fade a bottom sheet as it enters and exits, it creates distracting cross faded frames_
_altText: Message window remains transparent with details visible as it shrinks causing text beneath to become obscured._

### Simple style

Transitions are not receptive to highly stylized motion. They're frequent, often occupy large portions of the screen, and are primarily meant to help users accomplish a task.

_footer: Transitions should have a simple style_
_altText: Calendar event expands evenly and quickly comes to a rest._

_footer: Common transitions should not use overt style effects like bouncy springs_
_altText: Calendar event expands with window bouncing momentarily and bouncing again on collapse._

## Choosing a transition pattern

Consider the following to choose the right transition for a given use case:

### Container transform

This pattern is highly effective at creating a relationship between elements. It's also the most dramatic pattern in terms of style and should be reserved for the right context. Consider using it for:

- Hero moments that should be expressive
- Shallow hierarchies where you expand an element for more detail then collapse it
- Creating a seamless connection between elements

**Read the research for the benefits of container transform****[here](https://material.io/blog/motion-research-container-transform).**

_footer: A container transform creates a clear connection between the thumbnail and expanded image. It also makes this hero transition more expressive._
_altText: Image within a carousel is selected and expands to fill the screen._

_footer: Don't use container transform in apps with deep hierarchies, the motion becomes excessive. The expressive style also doesn't fit this utility focused navigation._
_altText: Battery life menu item among many setting options is selected and expanded to fill the screen._

Use a container transform transition for hero moments rather than a forward and backward transition.

_footer: Don't use forward and backward transitions on hero moments like opening a photo memory_
_altText: A One-Year-Ago photo memory is selected and expanded to take over the screen._

### Forward and backward

Both Android and iOS should use platform defaults for forward and backward navigation. It's easy to implement and stays current as platforms update. They have a simple motion style suitable for such a common transition.

_footer: Platform default forward and backward transitions are a sensible choice for common navigation_
_altText: Individual message is selected with simple motion, and moves back with simple motion._

_footer: Container transform transitions require custom implementations and the motion may feel excessive when used frequently_
_altText: Individual message is selected, causing a more radical take-over of the screen._

### Lateral

Lateral transitions are used to browse peer content that's part of the same set, like navigating between tabs in a media library. By sliding content horizontally, it hints at being able to swipe the content area to navigate between peers.

_footer: A tab component uses a lateral transition type_
_altText: Tabs in a music app shift horizontally without interruption when selected._

_footer: Fading content as it slides makes the peer relationship and swipe gesture less obvious. The style also may be confused with a forward and backward transition._
_altText: Tabs in a music app fade as they rotate horizontally._

Don't use a Lateral transition for navigating hierarchical screens. Sliding content the full width of the screen is excessive for a high frequency transition. It also implies an equal peer relationship which isn't accurate to the hierarchy of the screens.

_footer: A lateral transition should not be used for common forward and backward navigation as it results in an excessive amount of motion_
_altText: Message selected within messaging app moves laterally._

### Top level

When tapping a navigation bar, rail or drawer, a quick fade is used to transition to a new destination. Top level destinations aren't necessarily related, so the motion intentionally does not create a connection between screens.

A lateral transition pattern is not recommended for this type of navigation. It implies you can swipe between top level destinations which conflicts with other components like carousels or swipe-able list items.

_footer: A top level transition type is used with a navigation bar, rail and drawer_
_altText: Navigation between home and music app occurs with a quick fade, suggesting that items in each are distinct._

_footer: Don't use a lateral transition to move between top level destinations. The gesture conflicts with carousel and list item gestures._
_altText: Navigation between home a music app occurs in a seamless lateral scroll, falsely suggesting that items in each are connected._

### Enter and Exit

This transition pattern is used to introduce a component in context of the screen’s main UI. It can be modal, like a dialog requiring a user to take action. Or it can allow for simultaneously using both regions of the UI, like a standard bottom sheet over a map.

Don't use this pattern for navigating hierarchical screens. Sliding content the full height of the screen is excessive and it creates an unclear relationship between screens.

_footer: This bottom sheet uses an enter and exit transition pattern_
_altText: Animation showing a standard bottom sheet using the enter and exit transition over a map._

_footer: Don't use an enter and exit pattern for navigating hierarchical screens_
_altText: Animation showing a card expanding to a full screen on click and using the enter and exit transition._
