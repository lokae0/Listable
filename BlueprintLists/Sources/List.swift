//
//  List.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable


///
/// A Blueprint element which can be used to display a Listable `ListView` within
/// an element tree.
///
/// You should use the `List` element as follows, just like you'd use the `configure(with:)` method
/// on `ListView` itself.
/// ```
/// List { list in
///     list.content.header = HeaderFooter(PodcastsHeader())
///
///     let podcasts = Podcast.podcasts.sorted { $0.episode < $1.episode }
///
///     list += Section("podcasts") { section in
///
///         section.header = HeaderFooter(PodcastsSectionHeader())
///
///         section += podcasts.map { podcast in
///             PodcastRow(podcast: podcast)
///         }
///     }
/// }
/// ```
/// The parameter passed to the initialization closure is an instance of `ListProperties`,
/// which holds the various configuration options and content for the list. See `ListProperties` for
/// a full overview of all the configuration options available such as animation, layout configuration, etc.
///
/// When being laid out, a `List` will take up as much space as it is allowed. If you'd like to constrain
/// the size of a list, wrap it in a `ConstrainedSize`, or other size constraining element.
///
public struct List : Element
{
    /// The properties which back the on-screen list.
    ///
    /// When it comes time to render the `List` on screen,
    /// `ListView.configure(with: properties)` is called
    /// to update the on-screen list with the provided properties.
    public var properties : ListProperties
    
    /// How the `List` is measured when the element is laid out
    /// by Blueprint.  Defaults to `.fillParent`, which means
    /// it will take up all the size it is given. You can change this to
    /// `.measureContent` to instead measure the optimal size.
    ///
    /// See the `Sizing` documentation for more.
    public var sizing : Sizing
    
    //
    // MARK: Initialization
    //
        
    /// Create a new list, configured with the provided properties,
    /// configured with the provided `ListProperties` builder.
    public init(
        sizing : Sizing = .fillParent,
        build : ListProperties.Build
    ) {
        self.sizing = sizing
        
        self.properties = .default(with: build)
    }
    
    //
    // MARK: Element
    //
        
    public var content : ElementContent {
        ElementContent { constraint -> CGSize in
            switch self.sizing {
            case .fillParent:
                return constraint.maximum
                
            case .measureContent:
                return ListView.contentSize(in: constraint.maximum, for: self.properties)
            }
        }
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        ListView.describe { config in
            config.builder = {
                ListView(frame: bounds, appearance: self.properties.appearance)
            }
            
            config.apply { listView in
                listView.configure(with: self.properties)
            }
        }
    }
}


public extension List
{
    ///
    /// Provides the possible options for sizing a `List` when it is measured and laid out by Blueprint.
    ///
    /// You have two options: `.fillParent` and `.measureContent`.
    ///
    /// When using  `.fillParent`, the full available space will be taken up, regardless
    /// of the size of the content itself.
    ///
    /// When using `.measureContent`, the content will be measured within the provided space
    /// and that size will be returned as the size of the list element.
    /// ```
    /// .fillParent:
    /// ┌───────────┐
    /// │┌─────────┐│
    /// ││         ││
    /// ││         ││
    /// ││         ││
    /// ││         ││
    /// ││         ││
    /// │└─────────┘│
    /// └───────────┘
    ///
    /// .measureContent
    /// ┌───────────┐
    /// │           │
    /// │           │
    /// │┌─────────┐│
    /// ││         ││
    /// ││         ││
    /// ││         ││
    /// │└─────────┘│
    /// └───────────┘
    /// ```
    ///
    enum Sizing : Equatable
    {
        /// When using  `.fillParent`, the full available space will be taken up, regardless
        /// of the content size of the list itself.
        ///
        /// This is the setting you want to use when your list is being used to fill the content
        /// of a screen, such as if it is being presented in a navigation controller or tab bar controller.
        case fillParent
        
        /// When using `.measureContent`, the content will be measured within the provided space
        /// and that size will be returned as the size of the list element.
        ///
        /// If you are putting a list into a sheet or popover, this is generally the `Sizing` type
        /// you will want to use, to ensure the sheet or popover takes up the minimum amount of space possible.
        ///
        /// **Note**: This method may return both extremely short sizes (0 pts), or extremely tall
        /// sizes (1000, 10,000 pt, or more) depending on the content in your list. When using
        /// this option, you should usually wrap the `List` in a `ConstrainedSize` to avoid
        /// overflowing the parent element.
        case measureContent
    }
}
