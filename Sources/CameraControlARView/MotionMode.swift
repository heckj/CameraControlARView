/// A type that indicates the control mode used to adjust the perspective camera within an ARView.
public enum MotionMode: Int {
    /// Rotate around a target location, effectively orbiting and keeping the camera trained on it.
    ///
    /// Drag motions:
    /// - The view converts vertical drag distance into an inclination above, or below, the target location, clamped to directly above and below it.
    /// - The view converts horizontal drag distance into a rotational angle, orbiting the target location.
    /// - A magnify gesture zooms in, or out, from the target location.
    ///
    /// Keyboard motions:
    /// - The right-arrow and `d` keys rotate the camera to the right around the location.
    /// - The left-arrow and `a` keys rotate the camera to the left around the location.
    /// - The up-arrow and `w` keys rotate the camera upward around the location, clamped to a maximum of directly above the location.
    /// - The down-arrow and `s` keys rotate the camera downward around the location, clamped to a minimum of directly below the location.
    case arcball
    
    /// Free motion within the AR scene, not locked to a location.
    ///
    /// In general, the arrow keys or trackpad control where you're looking and the `a`,`s`,`d`, and `w` keys move you around.
    ///
    /// Drag motions:
    /// - A drag motion changes where the camera is looking.
    ///
    /// Keyboard motions:
    /// - The `d` key moves the camera in a strafing motion to the right.
    /// - The `a` key moves the camera in a strafing motion to the left.
    /// - The `w` key moves the camera forward.
    /// - The `s` key moves the camera backward.
    ///
    /// - The right-arrow key rotates the camera to the right..
    /// - The left-arrow key rotates the camera to the left.
    /// - The up-arrow key rotates the camera upward.
    /// - The down-arrow key rotates the camera downward.
    case firstperson
}

// arcball:
//
// At its heart, arcball is all about looking at a singular location (or object). It needs to have a
// radius as well.
//
// - vertical delta motion (drag) interpreted as changing the inclination angle. Which I think
// would make sense to clamp at +90° and -90° (+.pi/2, -.pi/2) to keep from getting really confusing.
// - horizontal delta motion (drag) interpreted as changing rotation angle. No need to clamp this.
// - keydown left-arrow, right-arrow get mapped to explicit increments of horizontal delta and change rotation
// - keydown up-arrow, down-arrow get mapped to explicit increments of vertical delta, and respect the clamping.
// - magnification (increase = zoom in) interpreted as shortening the radius to the target location, and
// zoom out does the reverse. Definitely clamp to a minimum of zero radius, and potentially want to have a
// lower set limit not to come earlier based on a collision boundary for any target object and maybe some padding.
