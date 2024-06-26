// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go k8s.io/api/apidiscovery/v2

package v2

import "k8s.io/apimachinery/pkg/apis/meta/v1"

// APIGroupDiscoveryList is a resource containing a list of APIGroupDiscovery.
// This is one of the types able to be returned from the /api and /apis endpoint and contains an aggregated
// list of API resources (built-ins, Custom Resource Definitions, resources from aggregated servers)
// that a cluster supports.
#APIGroupDiscoveryList: {
	v1.#TypeMeta

	// ResourceVersion will not be set, because this does not have a replayable ordering among multiple apiservers.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
	// +optional
	metadata?: v1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)

	// items is the list of groups for discovery. The groups are listed in priority order.
	items: [...#APIGroupDiscovery] @go(Items,[]APIGroupDiscovery) @protobuf(2,bytes,rep)
}

// APIGroupDiscovery holds information about which resources are being served for all version of the API Group.
// It contains a list of APIVersionDiscovery that holds a list of APIResourceDiscovery types served for a version.
// Versions are in descending order of preference, with the first version being the preferred entry.
#APIGroupDiscovery: {
	v1.#TypeMeta

	// Standard object's metadata.
	// The only field completed will be name. For instance, resourceVersion will be empty.
	// name is the name of the API group whose discovery information is presented here.
	// name is allowed to be "" to represent the legacy, ungroupified resources.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
	// +optional
	metadata?: v1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// versions are the versions supported in this group. They are sorted in descending order of preference,
	// with the preferred version being the first entry.
	// +listType=map
	// +listMapKey=version
	versions?: [...#APIVersionDiscovery] @go(Versions,[]APIVersionDiscovery) @protobuf(2,bytes,rep)
}

// APIVersionDiscovery holds a list of APIResourceDiscovery types that are served for a particular version within an API Group.
#APIVersionDiscovery: {
	// version is the name of the version within a group version.
	version: string @go(Version) @protobuf(1,bytes,opt)

	// resources is a list of APIResourceDiscovery objects for the corresponding group version.
	// +listType=map
	// +listMapKey=resource
	resources?: [...#APIResourceDiscovery] @go(Resources,[]APIResourceDiscovery) @protobuf(2,bytes,rep)

	// freshness marks whether a group version's discovery document is up to date.
	// "Current" indicates the discovery document was recently
	// refreshed. "Stale" indicates the discovery document could not
	// be retrieved and the returned discovery document may be
	// significantly out of date. Clients that require the latest
	// version of the discovery information be retrieved before
	// performing an operation should not use the aggregated document
	freshness?: #DiscoveryFreshness @go(Freshness) @protobuf(3,bytes,opt)
}

// APIResourceDiscovery provides information about an API resource for discovery.
#APIResourceDiscovery: {
	// resource is the plural name of the resource.  This is used in the URL path and is the unique identifier
	// for this resource across all versions in the API group.
	// Resources with non-empty groups are located at /apis/<APIGroupDiscovery.objectMeta.name>/<APIVersionDiscovery.version>/<APIResourceDiscovery.Resource>
	// Resources with empty groups are located at /api/v1/<APIResourceDiscovery.Resource>
	resource: string @go(Resource) @protobuf(1,bytes,opt)

	// responseKind describes the group, version, and kind of the serialization schema for the object type this endpoint typically returns.
	// APIs may return other objects types at their discretion, such as error conditions, requests for alternate representations, or other operation specific behavior.
	// This value will be null or empty if an APIService reports subresources but supports no operations on the parent resource
	responseKind?: null | v1.#GroupVersionKind @go(ResponseKind,*v1.GroupVersionKind) @protobuf(2,bytes,opt)

	// scope indicates the scope of a resource, either Cluster or Namespaced
	scope: #ResourceScope @go(Scope) @protobuf(3,bytes,opt)

	// singularResource is the singular name of the resource.  This allows clients to handle plural and singular opaquely.
	// For many clients the singular form of the resource will be more understandable to users reading messages and should be used when integrating the name of the resource into a sentence.
	// The command line tool kubectl, for example, allows use of the singular resource name in place of plurals.
	// The singular form of a resource should always be an optional element - when in doubt use the canonical resource name.
	singularResource: string @go(SingularResource) @protobuf(4,bytes,opt)

	// verbs is a list of supported API operation types (this includes
	// but is not limited to get, list, watch, create, update, patch,
	// delete, deletecollection, and proxy).
	// +listType=set
	verbs: [...string] @go(Verbs,[]string) @protobuf(5,bytes,opt)

	// shortNames is a list of suggested short names of the resource.
	// +listType=set
	shortNames?: [...string] @go(ShortNames,[]string) @protobuf(6,bytes,rep)

	// categories is a list of the grouped resources this resource belongs to (e.g. 'all').
	// Clients may use this to simplify acting on multiple resource types at once.
	// +listType=set
	categories?: [...string] @go(Categories,[]string) @protobuf(7,bytes,rep)

	// subresources is a list of subresources provided by this resource. Subresources are located at /apis/<APIGroupDiscovery.objectMeta.name>/<APIVersionDiscovery.version>/<APIResourceDiscovery.Resource>/name-of-instance/<APIResourceDiscovery.subresources[i].subresource>
	// +listType=map
	// +listMapKey=subresource
	subresources?: [...#APISubresourceDiscovery] @go(Subresources,[]APISubresourceDiscovery) @protobuf(8,bytes,rep)
}

// ResourceScope is an enum defining the different scopes available to a resource.
#ResourceScope: string // #enumResourceScope

#enumResourceScope:
	#ScopeCluster |
	#ScopeNamespace

#ScopeCluster:   #ResourceScope & "Cluster"
#ScopeNamespace: #ResourceScope & "Namespaced"

// DiscoveryFreshness is an enum defining whether the Discovery document published by an apiservice is up to date (fresh).
#DiscoveryFreshness: string // #enumDiscoveryFreshness

#enumDiscoveryFreshness:
	#DiscoveryFreshnessCurrent |
	#DiscoveryFreshnessStale

#DiscoveryFreshnessCurrent: #DiscoveryFreshness & "Current"
#DiscoveryFreshnessStale:   #DiscoveryFreshness & "Stale"

// APISubresourceDiscovery provides information about an API subresource for discovery.
#APISubresourceDiscovery: {
	// subresource is the name of the subresource.  This is used in the URL path and is the unique identifier
	// for this resource across all versions.
	subresource: string @go(Subresource) @protobuf(1,bytes,opt)

	// responseKind describes the group, version, and kind of the serialization schema for the object type this endpoint typically returns.
	// Some subresources do not return normal resources, these will have null or empty return types.
	responseKind?: null | v1.#GroupVersionKind @go(ResponseKind,*v1.GroupVersionKind) @protobuf(2,bytes,opt)

	// acceptedTypes describes the kinds that this endpoint accepts.
	// Subresources may accept the standard content types or define
	// custom negotiation schemes. The list may not be exhaustive for
	// all operations.
	// +listType=map
	// +listMapKey=group
	// +listMapKey=version
	// +listMapKey=kind
	acceptedTypes?: [...v1.#GroupVersionKind] @go(AcceptedTypes,[]v1.GroupVersionKind) @protobuf(3,bytes,rep)

	// verbs is a list of supported API operation types (this includes
	// but is not limited to get, list, watch, create, update, patch,
	// delete, deletecollection, and proxy). Subresources may define
	// custom verbs outside the standard Kubernetes verb set. Clients
	// should expect the behavior of standard verbs to align with
	// Kubernetes interaction conventions.
	// +listType=set
	verbs: [...string] @go(Verbs,[]string) @protobuf(4,bytes,opt)
}
