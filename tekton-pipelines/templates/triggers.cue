package templates

triggers: [{
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name: "tekton-triggers-admin"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["configmaps", "services", "events"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["apps"]
		resources: ["deployments", "deployments/finalizers"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["admissionregistration.k8s.io"]
		resources: ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["triggers.tekton.dev"]
		resources: ["clustertriggerbindings", "clusterinterceptors", "interceptors", "eventlisteners", "triggerbindings", "triggertemplates", "triggers", "eventlisteners/finalizers"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["triggers.tekton.dev"]
		resources: ["clustertriggerbindings/status", "clusterinterceptors/status", "interceptors/status", "eventlisteners/status", "triggerbindings/status", "triggertemplates/status", "triggers/status"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		// We uses leases for leaderelection
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["serving.knative.dev"]
		resources: ["*", "*/status", "*/finalizers"]
		verbs: ["get", "list", "create", "update", "delete", "deletecollection", "patch", "watch"]
	}, {
		apiGroups: [""]
		resources: ["namespaces"]
		verbs: ["get"]
		// The webhook configured the namespace as the OwnerRef on various cluster-scoped resources,
		// which requires we can Get the system namespace.
		resourceNames: ["tekton-pipelines"]
	}, {
		apiGroups: [""]
		resources: ["namespaces/finalizers"]
		verbs: ["update"]
		// The webhook configured the namespace as the OwnerRef on various cluster-scoped resources,
		// which requires we can update the system namespace finalizers.
		resourceNames: ["tekton-pipelines"]
	}]
}, {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name: "tekton-triggers-core-interceptors"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["get", "list", "watch"]
	}]
}, {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name: "tekton-triggers-core-interceptors-secrets"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: ["triggers.tekton.dev"]
		resources: ["clusterinterceptors"]
		verbs: ["get", "list", "watch", "update"]
	}, {
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["get", "list", "watch", "update"]
		resourceNames: ["tekton-triggers-core-interceptors-certs"]
	}]
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name: "tekton-triggers-eventlistener-roles"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: ["triggers.tekton.dev"]
		resources: ["eventlisteners", "triggerbindings", "interceptors", "triggertemplates", "triggers"]
		verbs: ["get", "list", "watch"]
	}, {
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["get", "list", "watch"]
	}, {
		apiGroups: ["tekton.dev"]
		resources: ["pipelineruns", "pipelineresources", "taskruns"]
		verbs: ["create"]
	}, {
		apiGroups: [""]
		resources: ["serviceaccounts"]
		verbs: ["impersonate"]
	}, {
		apiGroups: [""]
		resources: ["events"]
		verbs: ["create", "patch"]
	}]
}, {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name: "tekton-triggers-eventlistener-clusterroles"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: ["triggers.tekton.dev"]
		resources: ["clustertriggerbindings", "clusterinterceptors"]
		verbs: ["get", "list", "watch"]
	}, {
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["get", "list", "watch"]
	}]
}, {
	// Copyright 2020 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	// NOTE:  when multi-tenant EventListener progresses, moving this Role
	// to a ClusterRole is not the advisable path.  Additional Roles that
	// adds access to Secrets to the Namespaces managed by the multi-tenant
	// EventListener is what should be done.  While not as simple, it avoids
	// giving access to K8S system level, cluster admin privileged level Secrets

	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-triggers-admin-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}]
}, {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-triggers-core-interceptors"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["get", "list", "watch"]
	}]
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "tekton-triggers-info"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	rules: [{
		// All system:authenticated users needs to have access
		// of the triggers-info ConfigMap even if they don't
		// have access to the other resources present in the
		// installed namespace.
		apiGroups: [""]
		resources: ["configmaps"]
		resourceNames: ["triggers-info"]
		verbs: ["get"]
	}]
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      "tekton-triggers-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
}, {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      "tekton-triggers-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
}, {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      "tekton-triggers-core-interceptors"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-triggers-controller-admin"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-triggers-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-triggers-admin"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-triggers-webhook-admin"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-triggers-webhook"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-triggers-admin"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-triggers-core-interceptors"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-triggers-core-interceptors"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-triggers-core-interceptors"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-triggers-core-interceptors-secrets"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-triggers-core-interceptors"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-triggers-core-interceptors-secrets"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	// Copyright 2020 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-triggers-webhook-admin"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-triggers-webhook"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-triggers-admin-webhook"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-triggers-core-interceptors"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-triggers-core-interceptors"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-triggers-core-interceptors"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-triggers-info"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	subjects: [{
		// Giving all system:authenticated users the access of the
		// ConfigMap which contains version information.
		kind:     "Group"
		name:     "system:authenticated"
		apiGroup: "rbac.authorization.k8s.io"
	}]
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "tekton-triggers-info"
	}
}, {
	// Copyright 2021 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "clusterinterceptors.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Cluster"
		names: {
			kind:     "ClusterInterceptor"
			plural:   "clusterinterceptors"
			singular: "clusterinterceptor"
			shortNames: ["ci"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1alpha1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "clustertriggerbindings.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Cluster"
		names: {
			kind:     "ClusterTriggerBinding"
			plural:   "clustertriggerbindings"
			singular: "clustertriggerbinding"
			shortNames: ["ctb"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1beta1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			subresources: status: {}
		}, {
			name:    "v1alpha1"
			served:  true
			storage: false
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			subresources: status: {}
		}]
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "eventlisteners.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Namespaced"
		names: {
			kind:     "EventListener"
			plural:   "eventlisteners"
			singular: "eventlistener"
			shortNames: ["el"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1beta1"
			served:  true
			storage: true
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			additionalPrinterColumns: [{
				name:     "Address"
				type:     "string"
				jsonPath: ".status.address.url"
			}, {
				name:     "Available"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Available')].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Available')].reason"
			}, {
				name:     "Ready"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Ready')].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Ready')].reason"
			}]
		}, {
			name:    "v1alpha1"
			served:  true
			storage: false
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
			additionalPrinterColumns: [{
				name:     "Address"
				type:     "string"
				jsonPath: ".status.address.url"
			}, {
				name:     "Available"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Available')].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Available')].reason"
			}, {
				name:     "Ready"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Ready')].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Ready')].reason"
			}]
		}]
	}
}, {
	// Copyright 2022 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "interceptors.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Namespaced"
		names: {
			kind:     "Interceptor"
			plural:   "interceptors"
			singular: "interceptor"
			shortNames: ["ni"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1alpha1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "triggers.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Namespaced"
		names: {
			kind:     "Trigger"
			plural:   "triggers"
			singular: "trigger"
			shortNames: ["tri"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1beta1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			subresources: status: {}
		}, {
			name:    "v1alpha1"
			served:  true
			storage: false
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "triggerbindings.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Namespaced"
		names: {
			kind:     "TriggerBinding"
			plural:   "triggerbindings"
			singular: "triggerbinding"
			shortNames: ["tb"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1beta1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}, {
			name:    "v1alpha1"
			served:  true
			storage: false
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "triggertemplates.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			version:                       "v0.26.2"
		}
	}
	spec: {
		group: "triggers.tekton.dev"
		scope: "Namespaced"
		names: {
			kind:     "TriggerTemplate"
			plural:   "triggertemplates"
			singular: "triggertemplate"
			shortNames: ["tt"]
			categories: [
				"tekton",
				"tekton-triggers",
			]
		}
		versions: [{
			name:    "v1beta1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}, {
			name:    "v1alpha1"
			served:  true
			storage: false
			schema: openAPIV3Schema: {
				type: "object"
				// One can use x-kubernetes-preserve-unknown-fields: true
				// at the root of the schema (and inside any properties, additionalProperties)
				// to get the traditional CRD behaviour that nothing is pruned, despite
				// setting spec.preserveUnknownProperties: false.
				//
				// See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
				// See issue: https://github.com/knative/serving/issues/912
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
	}
}, {
	// Copyright 2020 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:      "triggers-webhook-certs"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
}, {
	// The data is populated at install time.

	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata: {
		name: "validation.webhook.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
	webhooks: [{
		admissionReviewVersions: ["v1"]
		clientConfig: service: {
			name:      "tekton-triggers-webhook"
			namespace: "tekton-pipelines"
		}
		failurePolicy: "Fail"
		sideEffects:   "None"
		name:          "validation.webhook.triggers.tekton.dev"
	}]
}, {
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "MutatingWebhookConfiguration"
	metadata: {
		name: "webhook.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
	webhooks: [{
		admissionReviewVersions: ["v1"]
		clientConfig: service: {
			name:      "tekton-triggers-webhook"
			namespace: "tekton-pipelines"
		}
		failurePolicy: "Fail"
		sideEffects:   "None"
		name:          "webhook.triggers.tekton.dev"
	}]
}, {
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata: {
		name: "config.webhook.triggers.tekton.dev"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
	webhooks: [{
		admissionReviewVersions: ["v1"]
		clientConfig: service: {
			name:      "tekton-triggers-webhook"
			namespace: "tekton-pipelines"
		}
		failurePolicy: "Fail"
		sideEffects:   "None"
		name:          "config.webhook.triggers.tekton.dev"
		namespaceSelector: matchExpressions: [{
			key:      "triggers.tekton.dev/release"
			operator: "Exists"
		}]
	}]
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name: "tekton-triggers-aggregate-edit"
		labels: {
			"app.kubernetes.io/instance":                   "default"
			"app.kubernetes.io/part-of":                    "tekton-triggers"
			"rbac.authorization.k8s.io/aggregate-to-edit":  "true"
			"rbac.authorization.k8s.io/aggregate-to-admin": "true"
		}
	}
	rules: [{
		apiGroups: ["triggers.tekton.dev"]
		resources: [
			"clustertriggerbindings",
			"clusterinterceptors",
			"eventlisteners",
			"interceptors",
			"triggers",
			"triggerbindings",
			"triggertemplates",
		]
		verbs: [
			"create",
			"delete",
			"deletecollection",
			"get",
			"list",
			"patch",
			"update",
			"watch",
		]
	}]
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name: "tekton-triggers-aggregate-view"
		labels: {
			"app.kubernetes.io/instance":                  "default"
			"app.kubernetes.io/part-of":                   "tekton-triggers"
			"rbac.authorization.k8s.io/aggregate-to-view": "true"
		}
	}
	rules: [{
		apiGroups: ["triggers.tekton.dev"]
		resources: [
			"clustertriggerbindings",
			"clusterinterceptors",
			"eventlisteners",
			"interceptors",
			"triggers",
			"triggerbindings",
			"triggertemplates",
		]
		verbs: [
			"get",
			"list",
			"watch",
		]
	}]
}, {
	// Copyright 2021 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-defaults-triggers"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	data: "_example": """
		################################
		#                              #
		#    EXAMPLE CONFIGURATION     #
		#                              #
		################################

		# This block is not actually functional configuration,
		# but serves to illustrate the available configuration
		# options and document them in a way that is accessible
		# to users that `kubectl edit` this config map.
		#
		# These sample configuration options may be copied out of
		# this example block and unindented to be in the data block
		# to actually change the configuration.

		# default-service-account contains the default service account name
		# to use for TaskRun and PipelineRun, if none is specified.
		default-service-account: \"default\"

		"""
}, {
	// Copyright 2021 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "feature-flags-triggers"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
	data: {
		// Setting this flag will determine which gated features are enabled.
		// Acceptable values are "stable" or "alpha".
		"enable-api-fields": "stable"
		// Setting this field with valid regex pattern matching the pattern will exclude labels from
		// getting added to resources created by the EventListener such as the deployment
		"labels-exclusion-pattern": ""
	}
}, {
	// Copyright 2021 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "triggers-info"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	data: {
		// Contains triggers version which can be queried by external
		// tools such as CLI. Elevated permissions are already given to
		// this ConfigMap such that even if we don't have access to
		// other resources in the namespace we still can have access to
		// this ConfigMap.
		version: "v0.26.2"
	}
}, {
	// Copyright 2023 Tekton Authors LLC
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-leader-election-triggers-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	data: "_example": """
		################################
		#                              #
		#    EXAMPLE CONFIGURATION     #
		#                              #
		################################
		# This block is not actually functional configuration,
		# but serves to illustrate the available configuration
		# options and document them in a way that is accessible
		# to users that `kubectl edit` this config map.
		#
		# These sample configuration options may be copied out of
		# this example block and unindented to be in the data block
		# to actually change the configuration.
		# lease-duration is how long non-leaders will wait to try to acquire the
		# lock; 15 seconds is the value used by core kubernetes controllers.
		lease-duration: \"60s\"
		# renew-deadline is how long a leader will try to renew the lease before
		# giving up; 10 seconds is the value used by core kubernetes controllers.
		renew-deadline: \"40s\"
		# retry-period is how long the leader election client waits between tries of
		# actions; 2 seconds is the value used by core kubernetes controllers.
		retry-period: \"10s\"
		# buckets is the number of buckets used to partition key space of each
		# Reconciler. If this number is M and the replica number of the controller
		# is N, the N replicas will compete for the M buckets. The owner of a
		# bucket will take care of the reconciling for the keys partitioned into
		# that bucket.
		buckets: \"1\"

		"""
}, {
	// Copyright 2023 Tekton Authors LLC
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-leader-election-triggers-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	data: "_example": """
		################################
		#                              #
		#    EXAMPLE CONFIGURATION     #
		#                              #
		################################
		# This block is not actually functional configuration,
		# but serves to illustrate the available configuration
		# options and document them in a way that is accessible
		# to users that `kubectl edit` this config map.
		#
		# These sample configuration options may be copied out of
		# this example block and unindented to be in the data block
		# to actually change the configuration.
		# lease-duration is how long non-leaders will wait to try to acquire the
		# lock; 15 seconds is the value used by core kubernetes controllers.
		lease-duration: \"60s\"
		# renew-deadline is how long a leader will try to renew the lease before
		# giving up; 10 seconds is the value used by core kubernetes controllers.
		renew-deadline: \"40s\"
		# retry-period is how long the leader election client waits between tries of
		# actions; 2 seconds is the value used by core kubernetes controllers.
		retry-period: \"10s\"
		# buckets is the number of buckets used to partition key space of each
		# Reconciler. If this number is M and the replica number of the controller
		# is N, the N replicas will compete for the M buckets. The owner of a
		# bucket will take care of the reconciling for the keys partitioned into
		# that bucket.
		buckets: \"1\"

		"""
}, {
	// Copyright 2019 Tekton Authors LLC
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-logging-triggers"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	data: {
		// Common configuration for all knative codebase
		"zap-logger-config": """
			{
			  \"level\": \"info\",
			  \"development\": false,
			  \"disableStacktrace\": true,
			  \"sampling\": {
			    \"initial\": 100,
			    \"thereafter\": 100
			  },
			  \"outputPaths\": [\"stdout\"],
			  \"errorOutputPaths\": [\"stderr\"],
			  \"encoding\": \"json\",
			  \"encoderConfig\": {
			    \"timeKey\": \"timestamp\",
			    \"levelKey\": \"severity\",
			    \"nameKey\": \"logger\",
			    \"callerKey\": \"caller\",
			    \"messageKey\": \"message\",
			    \"stacktraceKey\": \"stacktrace\",
			    \"lineEnding\": \"\",
			    \"levelEncoder\": \"\",
			    \"timeEncoder\": \"iso8601\",
			    \"durationEncoder\": \"\",
			    \"callerEncoder\": \"\"
			  }
			}

			"""

		// Log level overrides
		"loglevel.controller":    "info"
		"loglevel.webhook":       "info"
		"loglevel.eventlistener": "info"
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-observability-triggers"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-triggers"
		}
	}
	data: "_example": """
		################################
		#                              #
		#    EXAMPLE CONFIGURATION     #
		#                              #
		################################

		# This block is not actually functional configuration,
		# but serves to illustrate the available configuration
		# options and document them in a way that is accessible
		# to users that `kubectl edit` this config map.
		#
		# These sample configuration options may be copied out of
		# this example block and unindented to be in the data block
		# to actually change the configuration.

		# metrics.backend-destination field specifies the system metrics destination.
		# It supports either prometheus (the default) or stackdriver.
		# Note: Using stackdriver will incur additional charges
		metrics.backend-destination: prometheus

		# metrics.stackdriver-project-id field specifies the stackdriver project ID. This
		# field is optional. When running on GCE, application default credentials will be
		# used if this field is not provided.
		metrics.stackdriver-project-id: \"<your stackdriver project id>\"

		# metrics.allow-stackdriver-custom-metrics indicates whether it is allowed to send metrics to
		# Stackdriver using \"global\" resource type and custom metric type if the
		# metrics are not supported by \"knative_revision\" resource type. Setting this
		# flag to \"true\" could cause extra Stackdriver charge.
		# If metrics.backend-destination is not Stackdriver, this is ignored.
		metrics.allow-stackdriver-custom-metrics: \"false\"

		"""
}, {
	// Copyright 2019 Tekton Authors LLC
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.26.2"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			"triggers.tekton.dev/release": "v0.26.2"
			app:                           "tekton-triggers-controller"
			version:                       "v0.26.2"
		}
		name:      "tekton-triggers-controller"
		namespace: "tekton-pipelines"
	}
	spec: {
		ports: [{
			name:       "http-metrics"
			port:       9000
			protocol:   "TCP"
			targetPort: 9000
		}]
		selector: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
		}
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      "tekton-triggers-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.26.2"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			// tekton.dev/release value replaced with inputs.params.versionTag in triggers/tekton/publish.yaml
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
	spec: {
		replicas: 1
		selector: matchLabels: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "controller"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "default"
				"app.kubernetes.io/version":   "v0.26.2"
				"app.kubernetes.io/part-of":   "tekton-triggers"
				app:                           "tekton-triggers-controller"
				"triggers.tekton.dev/release": "v0.26.2"
				// version value replaced with inputs.params.versionTag in triggers/tekton/publish.yaml
				version: "v0.26.2"
			}
			spec: {
				serviceAccountName: "tekton-triggers-controller"
				containers: [{
					name:  "tekton-triggers-controller"
					image: "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/controller:v0.26.2@sha256:93053fc44a7da96556eae162528b57450e5764d199e41ac6c8412040ea8bf2e9"
					args: ["-logtostderr", "-stderrthreshold", "INFO", "-el-image", "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/eventlistenersink:v0.26.2@sha256:5c535b1c5dacb5f8b4350ecfbb9ceab2ad42ed3c3436b0c5e4e2dd7299f89663", "-el-port", "8080", "-el-security-context=true", "-el-events", "disable", "-el-readtimeout", "5", "-el-writetimeout", "40", "-el-idletimeout", "120", "-el-timeouthandler", "30", "-el-httpclient-readtimeout", "30", "-el-httpclient-keep-alive", "30", "-el-httpclient-tlshandshaketimeout", "10", "-el-httpclient-responseheadertimeout", "10", "-el-httpclient-expectcontinuetimeout", "1", "-period-seconds", "10", "-failure-threshold", "3"]
					env: [{
						name: "SYSTEM_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}, {
						name:  "CONFIG_LOGGING_NAME"
						value: "config-logging-triggers"
					}, {
						name:  "CONFIG_OBSERVABILITY_NAME"
						value: "config-observability-triggers"
					}, {
						name:  "CONFIG_DEFAULTS_NAME"
						value: "config-defaults-triggers"
					}, {
						name:  "METRICS_DOMAIN"
						value: "tekton.dev/triggers"
					}, {
						name:  "METRICS_PROMETHEUS_PORT"
						value: "9000"
					}, {
						name:  "CONFIG_LEADERELECTION_NAME"
						value: "config-leader-election-triggers-controllers"
					}]
					securityContext: {
						allowPrivilegeEscalation: false
						capabilities: drop: ["ALL"]
						// User 65532 is the distroless nonroot user ID
						runAsUser:    65532
						runAsGroup:   65532
						runAsNonRoot: true
						seccompProfile: type: "RuntimeDefault"
					}
				}]
			}
		}
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:      "tekton-triggers-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.26.2"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			app:                           "tekton-triggers-webhook"
			version:                       "v0.26.2"
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
	spec: {
		ports: [{
			name:       "https-webhook"
			port:       443
			targetPort: 8443
		}]
		selector: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
		}
	}
}, {
	// Copyright 2019 The Tekton Authors
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     https://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      "tekton-triggers-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.26.2"
			"app.kubernetes.io/part-of":   "tekton-triggers"
			// tekton.dev/release value replaced with inputs.params.versionTag in triggers/tekton/publish.yaml
			"triggers.tekton.dev/release": "v0.26.2"
		}
	}
	spec: {
		replicas: 1
		selector: matchLabels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-triggers"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "webhook"
				"app.kubernetes.io/component": "webhook"
				"app.kubernetes.io/instance":  "default"
				"app.kubernetes.io/version":   "v0.26.2"
				"app.kubernetes.io/part-of":   "tekton-triggers"
				app:                           "tekton-triggers-webhook"
				"triggers.tekton.dev/release": "v0.26.2"
				// version value replaced with inputs.params.versionTag in triggers/tekton/publish.yaml
				version: "v0.26.2"
			}
			spec: {
				serviceAccountName: "tekton-triggers-webhook"
				containers: [{
					name: "webhook"
					// This is the Go import path for the binary that is containerized
					// and substituted here.
					image: "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/webhook:v0.26.2@sha256:4d26c92624a5cdb24d7edb617404049d67fbb2232b97e2e30a7a96b6ca11ac2d"
					env: [{
						name: "SYSTEM_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}, {
						name:  "CONFIG_LOGGING_NAME"
						value: "config-logging-triggers"
					}, {
						name:  "WEBHOOK_SERVICE_NAME"
						value: "tekton-triggers-webhook"
					}, {
						name:  "WEBHOOK_SECRET_NAME"
						value: "triggers-webhook-certs"
					}, {
						name:  "METRICS_DOMAIN"
						value: "tekton.dev/triggers"
					}, {
						name:  "CONFIG_LEADERELECTION_NAME"
						value: "config-leader-election-triggers-webhook"
					}]
					ports: [{
						name:          "metrics"
						containerPort: 9000
					}, {
						name:          "profiling"
						containerPort: 8008
					}, {
						name:          "https-webhook"
						containerPort: 8443
					}]
					securityContext: {
						allowPrivilegeEscalation: false
						// User 65532 is the distroless nonroot user ID
						runAsUser:    65532
						runAsGroup:   65532
						runAsNonRoot: true
						capabilities: drop: ["ALL"]
						seccompProfile: type: "RuntimeDefault"
					}
				}]
			}
		}
	}
}]
