package templates

pipeline: [{
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
	kind:       "Namespace"
	metadata: {
		name: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance":         "default"
			"app.kubernetes.io/part-of":          "tekton-pipelines"
			"pod-security.kubernetes.io/enforce": "restricted"
		}
	}
}, {
	// Copyright 2020-2022 The Tekton Authors
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

	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name: "tekton-pipelines-controller-cluster-access"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		apiGroups: [""]
		// Controller needs to watch Pods created by TaskRuns to see them progress.
		resources: ["pods"]
		verbs: ["list", "watch"]
	}, {
		apiGroups: [""]
		// Controller needs to get the list of cordoned nodes over the course of a single run
		resources: ["nodes"]
		verbs: ["list"]
	}, {
		// Controller needs cluster access to all of the CRDs that it is responsible for
		// managing.
		apiGroups: ["tekton.dev"]
		resources: ["tasks", "clustertasks", "taskruns", "pipelines", "pipelineruns", "customruns", "stepactions"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["tekton.dev"]
		resources: ["verificationpolicies"]
		verbs: ["get", "list", "watch"]
	}, {
		apiGroups: ["tekton.dev"]
		resources: ["taskruns/finalizers", "pipelineruns/finalizers", "customruns/finalizers"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		apiGroups: ["tekton.dev"]
		resources: ["tasks/status", "clustertasks/status", "taskruns/status", "pipelines/status", "pipelineruns/status", "customruns/status", "verificationpolicies/status", "stepactions/status"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		// resolution.tekton.dev
		apiGroups: ["resolution.tekton.dev"]
		resources: ["resolutionrequests", "resolutionrequests/status"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}]
}, {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		// This is the access that the controller needs on a per-namespace basis.
		name: "tekton-pipelines-controller-tenant-access"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		// Read-write access to create Pods and PVCs (for Workspaces)
		apiGroups: [""]
		resources: ["pods", "persistentvolumeclaims"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}, {
		// Write permissions to publish events.
		apiGroups: [""]
		resources: ["events"]
		verbs: ["create", "update", "patch"]
	}, {
		// Read-only access to these.
		apiGroups: [""]
		resources: ["configmaps", "limitranges", "secrets", "serviceaccounts"]
		verbs: ["get", "list", "watch"]
	}, {
		// Read-write access to StatefulSets for Affinity Assistant.
		apiGroups: ["apps"]
		resources: ["statefulsets"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}]
}, {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name: "tekton-pipelines-webhook-cluster-access"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		// The webhook needs to be able to get and update customresourcedefinitions,
		// mainly to update the webhook certificates.
		apiGroups: ["apiextensions.k8s.io"]
		resources: ["customresourcedefinitions", "customresourcedefinitions/status"]
		verbs: ["get", "update", "patch"]
		resourceNames: [
			"pipelines.tekton.dev",
			"pipelineruns.tekton.dev",
			"tasks.tekton.dev",
			"clustertasks.tekton.dev",
			"taskruns.tekton.dev",
			"resolutionrequests.resolution.tekton.dev",
			"customruns.tekton.dev",
			"verificationpolicies.tekton.dev",
			"stepactions.tekton.dev",
		]
	}, {
		// knative.dev/pkg needs list/watch permissions to set up informers for the webhook.
		apiGroups: ["apiextensions.k8s.io"]
		resources: ["customresourcedefinitions"]
		verbs: ["list", "watch"]
	}, {
		apiGroups: ["admissionregistration.k8s.io"]
		// The webhook performs a reconciliation on these two resources and continuously
		// updates configuration.
		resources: ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
		// knative starts informers on these things, which is why we need get, list and watch.
		verbs: ["list", "watch"]
	}, {
		apiGroups: ["admissionregistration.k8s.io"]
		resources: ["mutatingwebhookconfigurations"]
		// This mutating webhook is responsible for applying defaults to tekton objects
		// as they are received.
		resourceNames: ["webhook.pipeline.tekton.dev"]
		// When there are changes to the configs or secrets, knative updates the mutatingwebhook config
		// with the updated certificates or the refreshed set of rules.
		verbs: ["get", "update", "delete"]
	}, {
		apiGroups: ["admissionregistration.k8s.io"]
		resources: ["validatingwebhookconfigurations"]
		// validation.webhook.pipeline.tekton.dev performs schema validation when you, for example, create TaskRuns.
		// config.webhook.pipeline.tekton.dev validates the logging configuration against knative's logging structure
		resourceNames: ["validation.webhook.pipeline.tekton.dev", "config.webhook.pipeline.tekton.dev"]
		// When there are changes to the configs or secrets, knative updates the validatingwebhook config
		// with the updated certificates or the refreshed set of rules.
		verbs: ["get", "update", "delete"]
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
		name: "tekton-events-controller-cluster-access"
		labels: {
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		apiGroups: ["tekton.dev"]
		resources: ["tasks", "clustertasks", "taskruns", "pipelines", "pipelineruns", "customruns"]
		verbs: ["get", "list", "watch"]
	}]
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

	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["list", "watch"]
	}, {
		// The controller needs access to these configmaps for logging information and runtime configuration.
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["get"]
		resourceNames: ["config-logging", "config-observability", "feature-flags", "config-leader-election-controller", "config-registry-cert"]
	}]
}, {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["list", "watch"]
	}, {
		// The webhook needs access to these configmaps for logging information.
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["get"]
		resourceNames: ["config-logging", "config-observability", "config-leader-election-webhook", "feature-flags"]
	}, {
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["list", "watch"]
	}, {
		// The webhook daemon makes a reconciliation loop on webhook-certs. Whenever
		// the secret changes it updates the webhook configurations with the certificates
		// stored in the secret.
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["get", "update"]
		resourceNames: ["webhook-certs"]
	}]
}, {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-pipelines-events-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["list", "watch"]
	}, {
		// The controller needs access to these configmaps for logging information and runtime configuration.
		apiGroups: [""]
		resources: ["configmaps"]
		verbs: ["get"]
		resourceNames: ["config-logging", "config-observability", "feature-flags", "config-leader-election-events", "config-registry-cert"]
	}]
}, {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-pipelines-leader-election"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
	rules: [{
		// We uses leases for leaderelection
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}]
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "tekton-pipelines-info"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
	rules: [{
		// All system:authenticated users needs to have access
		// of the pipelines-info ConfigMap even if they don't
		// have access to the other resources present in the
		// installed namespace.
		apiGroups: [""]
		resources: ["configmaps"]
		resourceNames: ["pipelines-info"]
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
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
}, {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
}, {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      "tekton-events-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
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
		name: "tekton-pipelines-controller-cluster-access"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-pipelines-controller-cluster-access"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	// If this ClusterRoleBinding is replaced with a RoleBinding
	// then the ClusterRole would be namespaced. The access described by
	// the tekton-pipelines-controller-tenant-access ClusterRole would
	// be scoped to individual tenant namespaces.
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-pipelines-controller-tenant-access"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-pipelines-controller-tenant-access"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-pipelines-webhook-cluster-access"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-pipelines-webhook-cluster-access"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-events-controller-cluster-access"
		labels: {
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-events-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-events-controller-cluster-access"
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
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-controller"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-webhook"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-pipelines-controller-leaderelection"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-leader-election"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-pipelines-webhook-leaderelection"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-leader-election"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-pipelines-info"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		name:     "tekton-pipelines-info"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-pipelines-events-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-events-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-events-controller"
		apiGroup: "rbac.authorization.k8s.io"
	}
}, {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-events-controller-leaderelection"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-events-controller"
		namespace: "tekton-pipelines"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-leader-election"
		apiGroup: "rbac.authorization.k8s.io"
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
		name: "clustertasks.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
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
		}]
		names: {
			kind:     "ClusterTask"
			plural:   "clustertasks"
			singular: "clustertask"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
		}
		scope: "Cluster"
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

	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name: "customruns.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
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
			additionalPrinterColumns: [{
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].reason"
			}, {
				name:     "StartTime"
				type:     "date"
				jsonPath: ".status.startTime"
			}, {
				name:     "CompletionTime"
				type:     "date"
				jsonPath: ".status.completionTime"
			}]
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
		names: {
			kind:     "CustomRun"
			plural:   "customruns"
			singular: "customrun"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
		}
		scope: "Namespaced"
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
		name: "pipelines.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
		versions: [{
			name:    "v1beta1"
			served:  true
			storage: false
			subresources: status: {}
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
		}, {
			name:    "v1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// OpenAPIV3 schema allows Kubernetes to perform validation on the schema fields
				// and use the schema in tooling such as `kubectl explain`.
				// Using "x-kubernetes-preserve-unknown-fields: true"
				// at the root of the schema (or within it) allows arbitrary fields.
				// We currently perform our own validation separately.
				// See https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#specifying-a-structural-schema
				// for more info.
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
		names: {
			kind:     "Pipeline"
			plural:   "pipelines"
			singular: "pipeline"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
		}
		scope: "Namespaced"
		conversion: {
			strategy: "Webhook"
			webhook: {
				conversionReviewVersions: ["v1beta1", "v1"]
				clientConfig: service: {
					name:      "tekton-pipelines-webhook"
					namespace: "tekton-pipelines"
				}
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
		name: "pipelineruns.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
		versions: [{
			name:    "v1beta1"
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
			additionalPrinterColumns: [{
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].reason"
			}, {
				name:     "StartTime"
				type:     "date"
				jsonPath: ".status.startTime"
			}, {
				name:     "CompletionTime"
				type:     "date"
				jsonPath: ".status.completionTime"
			}]
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}, {
			name:    "v1"
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
			additionalPrinterColumns: [{
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].reason"
			}, {
				name:     "StartTime"
				type:     "date"
				jsonPath: ".status.startTime"
			}, {
				name:     "CompletionTime"
				type:     "date"
				jsonPath: ".status.completionTime"
			}]
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
		names: {
			kind:     "PipelineRun"
			plural:   "pipelineruns"
			singular: "pipelinerun"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
			shortNames: [
				"pr",
				"prs",
			]
		}
		scope: "Namespaced"
		conversion: {
			strategy: "Webhook"
			webhook: {
				conversionReviewVersions: ["v1beta1", "v1"]
				clientConfig: service: {
					name:      "tekton-pipelines-webhook"
					namespace: "tekton-pipelines"
				}
			}
		}
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
		name: "resolutionrequests.resolution.tekton.dev"
		labels: "resolution.tekton.dev/release": "devel"
	}
	spec: {
		group: "resolution.tekton.dev"
		scope: "Namespaced"
		names: {
			kind:     "ResolutionRequest"
			plural:   "resolutionrequests"
			singular: "resolutionrequest"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
			shortNames: [
				"resolutionrequest",
				"resolutionrequests",
			]
		}
		versions: [{
			name:       "v1alpha1"
			served:     true
			deprecated: true
			storage:    false
			subresources: status: {}
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
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Succeeded')].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Succeeded')].reason"
			}]
		}, {
			name:    "v1beta1"
			served:  true
			storage: true
			subresources: status: {}
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
				name:     "OwnerKind"
				type:     "string"
				jsonPath: ".metadata.ownerReferences[0].kind"
			}, {
				name:     "Owner"
				type:     "string"
				jsonPath: ".metadata.ownerReferences[0].name"
			}, {
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Succeeded')].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Succeeded')].reason"
			}, {
				name:     "StartTime"
				type:     "string"
				jsonPath: ".metadata.creationTimestamp"
			}, {
				name:     "EndTime"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type=='Succeeded')].lastTransitionTime"
			}]
		}]
		conversion: {
			strategy: "Webhook"
			webhook: {
				conversionReviewVersions: ["v1alpha1", "v1beta1"]
				clientConfig: service: {
					name:      "tekton-pipelines-webhook"
					namespace: "tekton-pipelines"
				}
			}
		}
	}
}, {
	// Copyright 2023 The Tekton Authors
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
		name: "stepactions.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
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
		names: {
			kind:     "StepAction"
			plural:   "stepactions"
			singular: "stepaction"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
		}
		scope: "Namespaced"
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
		name: "tasks.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
		versions: [{
			name:    "v1beta1"
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
		}, {
			name:    "v1"
			served:  true
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				// TODO(#1461): Add OpenAPIV3 schema
				// OpenAPIV3 schema allows Kubernetes to perform validation on the schema fields
				// and use the schema in tooling such as `kubectl explain`.
				// Using "x-kubernetes-preserve-unknown-fields: true"
				// at the root of the schema (or within it) allows arbitrary fields.
				// We currently perform our own validation separately.
				// See https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#specifying-a-structural-schema
				// for more info.
				"x-kubernetes-preserve-unknown-fields": true
			}
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
		names: {
			kind:     "Task"
			plural:   "tasks"
			singular: "task"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
		}
		scope: "Namespaced"
		conversion: {
			strategy: "Webhook"
			webhook: {
				conversionReviewVersions: ["v1beta1", "v1"]
				clientConfig: service: {
					name:      "tekton-pipelines-webhook"
					namespace: "tekton-pipelines"
				}
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
		name: "taskruns.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group:                 "tekton.dev"
		preserveUnknownFields: false
		versions: [{
			name:    "v1beta1"
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
			additionalPrinterColumns: [{
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].reason"
			}, {
				name:     "StartTime"
				type:     "date"
				jsonPath: ".status.startTime"
			}, {
				name:     "CompletionTime"
				type:     "date"
				jsonPath: ".status.completionTime"
			}]
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}, {
			name:    "v1"
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
			additionalPrinterColumns: [{
				name:     "Succeeded"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].status"
			}, {
				name:     "Reason"
				type:     "string"
				jsonPath: ".status.conditions[?(@.type==\"Succeeded\")].reason"
			}, {
				name:     "StartTime"
				type:     "date"
				jsonPath: ".status.startTime"
			}, {
				name:     "CompletionTime"
				type:     "date"
				jsonPath: ".status.completionTime"
			}]
			// Opt into the status subresource so metadata.generation
			// starts to increment
			subresources: {
				status: {}
			}
		}]
		names: {
			kind:     "TaskRun"
			plural:   "taskruns"
			singular: "taskrun"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
			shortNames: [
				"tr",
				"trs",
			]
		}
		scope: "Namespaced"
		conversion: {
			strategy: "Webhook"
			webhook: {
				conversionReviewVersions: ["v1beta1", "v1"]
				clientConfig: service: {
					name:      "tekton-pipelines-webhook"
					namespace: "tekton-pipelines"
				}
			}
		}
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
		name: "verificationpolicies.tekton.dev"
		labels: {
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
			version:                       "v0.59.0"
		}
	}
	spec: {
		group: "tekton.dev"
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
		}]
		names: {
			kind:     "VerificationPolicy"
			plural:   "verificationpolicies"
			singular: "verificationpolicy"
			categories: [
				"tekton",
				"tekton-pipelines",
			]
		}
		scope: "Namespaced"
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
		name:      "webhook-certs"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
		}
	}
}, {
	// The data is populated at install time.

	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata: {
		name: "validation.webhook.pipeline.tekton.dev"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
		}
	}
	webhooks: [{
		admissionReviewVersions: ["v1"]
		clientConfig: service: {
			name:      "tekton-pipelines-webhook"
			namespace: "tekton-pipelines"
		}
		failurePolicy: "Fail"
		sideEffects:   "None"
		name:          "validation.webhook.pipeline.tekton.dev"
	}]
}, {
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "MutatingWebhookConfiguration"
	metadata: {
		name: "webhook.pipeline.tekton.dev"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
		}
	}
	webhooks: [{
		admissionReviewVersions: ["v1"]
		clientConfig: service: {
			name:      "tekton-pipelines-webhook"
			namespace: "tekton-pipelines"
		}
		failurePolicy: "Fail"
		sideEffects:   "None"
		name:          "webhook.pipeline.tekton.dev"
	}]
}, {
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata: {
		name: "config.webhook.pipeline.tekton.dev"
		labels: {
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			"pipeline.tekton.dev/release": "v0.59.0"
		}
	}
	webhooks: [{
		admissionReviewVersions: ["v1"]
		clientConfig: service: {
			name:      "tekton-pipelines-webhook"
			namespace: "tekton-pipelines"
		}
		failurePolicy: "Fail"
		sideEffects:   "None"
		name:          "config.webhook.pipeline.tekton.dev"
		objectSelector: matchLabels: "app.kubernetes.io/part-of": "tekton-pipelines"
	}]
}, {
	// Copyright 2019-2022 The Tekton Authors
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

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name: "tekton-aggregate-edit"
		labels: {
			"app.kubernetes.io/instance":                   "default"
			"app.kubernetes.io/part-of":                    "tekton-pipelines"
			"rbac.authorization.k8s.io/aggregate-to-edit":  "true"
			"rbac.authorization.k8s.io/aggregate-to-admin": "true"
		}
	}
	rules: [{
		apiGroups: ["tekton.dev"]
		resources: [
			"tasks",
			"taskruns",
			"pipelines",
			"pipelineruns",
			"runs",
			"customruns",
			"stepactions",
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
	// Copyright 2019-2022 The Tekton Authors
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

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name: "tekton-aggregate-view"
		labels: {
			"app.kubernetes.io/instance":                  "default"
			"app.kubernetes.io/part-of":                   "tekton-pipelines"
			"rbac.authorization.k8s.io/aggregate-to-view": "true"
		}
	}
	rules: [{
		apiGroups: ["tekton.dev"]
		resources: [
			"tasks",
			"taskruns",
			"pipelines",
			"pipelineruns",
			"runs",
			"customruns",
			"stepactions",
		]
		verbs: [
			"get",
			"list",
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
		name:      "config-defaults"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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

		# default-timeout-minutes contains the default number of
		# minutes to use for TaskRun and PipelineRun, if none is specified.
		default-timeout-minutes: \"60\"  # 60 minutes

		# default-service-account contains the default service account name
		# to use for TaskRun and PipelineRun, if none is specified.
		default-service-account: \"default\"

		# default-managed-by-label-value contains the default value given to the
		# \"app.kubernetes.io/managed-by\" label applied to all Pods created for
		# TaskRuns. If a user's requested TaskRun specifies another value for this
		# label, the user's request supercedes.
		default-managed-by-label-value: \"tekton-pipelines\"

		# default-pod-template contains the default pod template to use for
		# TaskRun and PipelineRun. If a pod template is specified on the
		# PipelineRun, the default-pod-template is merged with that one.
		# default-pod-template:

		# default-affinity-assistant-pod-template contains the default pod template
		# to use for affinity assistant pods. If a pod template is specified on the
		# PipelineRun, the default-affinity-assistant-pod-template is merged with
		# that one.
		# default-affinity-assistant-pod-template:

		# default-cloud-events-sink contains the default CloudEvents sink to be
		# used for TaskRun and PipelineRun, when no sink is specified.
		# Note that right now it is still not possible to set a PipelineRun or
		# TaskRun specific sink, so the default is the only option available.
		# If no sink is specified, no CloudEvent is generated
		# default-cloud-events-sink:

		# default-task-run-workspace-binding contains the default workspace
		# configuration provided for any Workspaces that a Task declares
		# but that a TaskRun does not explicitly provide.
		# default-task-run-workspace-binding: |
		#   emptyDir: {}

		# default-max-matrix-combinations-count contains the default maximum number
		# of combinations from a Matrix, if none is specified.
		default-max-matrix-combinations-count: \"256\"

		# default-forbidden-env contains comma seperated environment variables that cannot be
		# overridden by podTemplate.
		default-forbidden-env:

		# default-resolver-type contains the default resolver type to be used in the cluster,
		# no default-resolver-type is specified by default
		default-resolver-type:

		# default-imagepullbackoff-timeout contains the default duration to wait
		# before requeuing the TaskRun to retry, specifying 0 here is equivalent to fail fast
		# possible values could be 1m, 5m, 10s, 1h, etc
		# default-imagepullbackoff-timeout: \"5m\"

		# default-container-resource-requirements allow users to update default resource requirements
		# to a init-containers and containers of a pods create by the controller
		# Onet: All the resource requirements are applied to init-containers and containers
		# only if the existing resource requirements are empty.
		# default-container-resource-requirements: |
		#   place-scripts: # updates resource requirements of a 'place-scripts' container
		#     requests:
		#       memory: \"64Mi\"
		#       cpu: \"250m\"
		#     limits:
		#       memory: \"128Mi\"
		#       cpu: \"500m\"
		#
		#   prepare: # updates resource requirements of a 'prepare' container
		#     requests:
		#       memory: \"64Mi\"
		#       cpu: \"250m\"
		#     limits:
		#       memory: \"256Mi\"
		#       cpu: \"500m\"
		#
		#   working-dir-initializer: # updates resource requirements of a 'working-dir-initializer' container
		#     requests:
		#       memory: \"64Mi\"
		#       cpu: \"250m\"
		#     limits:
		#       memory: \"512Mi\"
		#       cpu: \"500m\"
		#
		#   prefix-scripts: # updates resource requirements of containers which starts with 'scripts-'
		#     requests:
		#       memory: \"64Mi\"
		#       cpu: \"250m\"
		#     limits:
		#       memory: \"128Mi\"
		#       cpu: \"500m\"
		#
		#   prefix-sidecar-scripts: # updates resource requirements of containers which starts with 'sidecar-scripts-'
		#     requests:
		#       memory: \"64Mi\"
		#       cpu: \"250m\"
		#     limits:
		#       memory: \"128Mi\"
		#       cpu: \"500m\"
		#
		#   default: # updates resource requirements of init-containers and containers which has empty resource resource requirements
		#     requests:
		#       memory: \"64Mi\"
		#       cpu: \"250m\"
		#     limits:
		#       memory: \"256Mi\"
		#       cpu: \"500m\"

		"""
}, {
	// Copyright 2023 The Tekton Authors
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
		name:      "config-events"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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

		# formats contains a comma seperated list of event formats to be used
		# the only format supported today is \"tektonv1\". An empty string is not
		# a valid configuration. To disable events, do not specify the sink.
		formats: \"tektonv1\"

		# sink contains the event sink to be used for TaskRun, PipelineRun and
		# CustomRun. If no sink is specified, no CloudEvent is generated.
		# This setting supercedes the \"default-cloud-events-sink\" from the
		# \"config-defaults\" config map
		sink: \"https://events.sink/cdevents\"

		"""
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
		name:      "feature-flags"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
	data: {
		// Setting this flag to "true" will prevent Tekton to create an
		// Affinity Assistant for every TaskRun sharing a PVC workspace
		//
		// The default behaviour is for Tekton to create Affinity Assistants
		//
		// See more in the Affinity Assistant documentation
		// https://github.com/tektoncd/pipeline/blob/main/docs/affinityassistants.md
		// or https://github.com/tektoncd/pipeline/pull/2630 for more info.
		//
		// Note: This feature flag is deprecated and will be removed in release v0.60. Consider using `coschedule` feature flag to configure Affinity Assistant behavior.
		"disable-affinity-assistant": "false"
		// Setting this flag will determine how PipelineRun Pods are scheduled with Affinity Assistant.
		// Acceptable values are "workspaces" (default), "pipelineruns", "isolate-pipelinerun", or "disabled".
		//
		// Setting it to "workspaces" will schedule all the taskruns sharing the same PVC-based workspace in a pipelinerun to the same node.
		// Setting it to "pipelineruns" will schedule all the taskruns in a pipelinerun to the same node.
		// Setting it to "isolate-pipelinerun" will schedule all the taskruns in a pipelinerun to the same node,
		// and only allows one pipelinerun to run on a node at a time.
		// Setting it to "disabled" will not apply any coschedule policy.
		//
		// See more in the Affinity Assistant documentation
		// https://github.com/tektoncd/pipeline/blob/main/docs/affinityassistants.md
		coschedule: "workspaces"
		// Setting this flag to "true" will prevent Tekton scanning attached
		// service accounts and injecting any credentials it finds into your
		// Steps.
		//
		// The default behaviour currently is for Tekton to search service
		// accounts for secrets matching a specified format and automatically
		// mount those into your Steps.
		//
		// Note: setting this to "true" will prevent PipelineResources from
		// working.
		//
		// See https://github.com/tektoncd/pipeline/issues/2791 for more
		// info.
		"disable-creds-init": "false"
		// Setting this flag to "false" will stop Tekton from waiting for a
		// TaskRun's sidecar containers to be running before starting the first
		// step. This will allow Tasks to be run in environments that don't
		// support the DownwardAPI volume type, but may lead to unintended
		// behaviour if sidecars are used.
		//
		// See https://github.com/tektoncd/pipeline/issues/4937 for more info.
		"await-sidecar-readiness": "true"
		// This option should be set to false when Pipelines is running in a
		// cluster that does not use injected sidecars such as Istio. Setting
		// it to false should decrease the time it takes for a TaskRun to start
		// running. For clusters that use injected sidecars, setting this
		// option to false can lead to unexpected behavior.
		//
		// See https://github.com/tektoncd/pipeline/issues/2080 for more info.
		"running-in-environment-with-injected-sidecars": "true"
		// Setting this flag to "true" will require that any Git SSH Secret
		// offered to Tekton must have known_hosts included.
		//
		// See https://github.com/tektoncd/pipeline/issues/2981 for more
		// info.
		"require-git-ssh-secret-known-hosts": "false"
		// Setting this flag to "true" enables the use of Tekton OCI bundle.
		// This is an experimental feature and thus should still be considered
		// an alpha feature.
		"enable-tekton-oci-bundles": "false"
		// Setting this flag will determine which gated features are enabled.
		// Acceptable values are "stable", "beta", or "alpha".
		"enable-api-fields": "beta"
		// Setting this flag to "true" enables CloudEvents for CustomRuns and Runs, as long as a
		// CloudEvents sink is configured in the config-defaults config map
		"send-cloudevents-for-runs": "false"
		// This flag affects the behavior of taskruns and pipelineruns in cases where no VerificationPolicies match them.
		// If it is set to "fail", TaskRuns and PipelineRuns will fail verification if no matching policies are found.
		// If it is set to "warn", TaskRuns and PipelineRuns will run to completion if no matching policies are found, and an error will be logged.
		// If it is set to "ignore", TaskRuns and PipelineRuns will run to completion if no matching policies are found, and no error will be logged.
		"trusted-resources-verification-no-match-policy": "ignore"
		// Setting this flag to "true" enables populating the "provenance" field in TaskRun
		// and PipelineRun status. This field contains metadata about resources used
		// in the TaskRun/PipelineRun such as the source from where a remote Task/Pipeline
		// definition was fetched.
		"enable-provenance-in-status": "true"
		// Setting this flag will determine how Tekton pipelines will handle non-falsifiable provenance.
		// If set to "spire", then SPIRE will be used to ensure non-falsifiable provenance.
		// If set to "none", then Tekton will not have non-falsifiable provenance.
		// This is an experimental feature and thus should still be considered an alpha feature.
		"enforce-nonfalsifiability": "none"
		// Setting this flag will determine how Tekton pipelines will handle extracting results from the task.
		// Acceptable values are "termination-message" or "sidecar-logs".
		// "sidecar-logs" is an experimental feature and thus should still be considered
		// an alpha feature.
		"results-from": "termination-message"
		// Setting this flag will determine the upper limit of each task result
		// This flag is optional and only associated with the previous flag, results-from
		// When results-from is set to "sidecar-logs", this flag can be used to configure the upper limit of a task result
		// max-result-size: "4096"
		// Setting this flag to "true" will limit privileges for containers injected by Tekton into TaskRuns.
		// This allows TaskRuns to run in namespaces with "restricted" pod security standards.
		// Not all Kubernetes implementations support this option.
		"set-security-context": "false"
		// Setting this flag to "true" will keep pod on cancellation
		// allowing examination of the logs on the pods from cancelled taskruns
		"keep-pod-on-cancel": "false"
		// Setting this flag to "true" will enable the CEL evaluation in WhenExpression
		"enable-cel-in-whenexpression": "false"
		// Setting this flag to "true" will enable the use of StepActions in Steps
		// This feature is in preview mode and not implemented yet. Please check #7259 for updates.
		"enable-step-actions": "false"
		// Setting this flag to "true" will enable the use of Artifacts in Steps
		// This feature is in preview mode and not implemented yet. Please check #7693 for updates.
		"enable-artifacts": "false"
		// Setting this flag to "true" will enable the built-in param input validation via param enum.
		"enable-param-enum": "false"
		// Setting this flag to "pipeline,pipelinerun,taskrun" will prevent users from creating
		// embedded spec Taskruns or Pipelineruns for Pipeline, Pipelinerun and taskrun
		// respectively. We can specify "pipeline" to disable for Pipeline resource only.
		// "pipelinerun" for Pipelinerun and "taskrun" for Taskrun. Or a combination of
		// these.
		"disable-inline-spec": ""
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
		name:      "pipelines-info"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
	data: {
		// Contains pipelines version which can be queried by external
		// tools such as CLI. Elevated permissions are already given to
		// this ConfigMap such that even if we don't have access to
		// other resources in the namespace we still can have access to
		// this ConfigMap.
		version: "v0.59.0"
	}
}, {
	// Copyright 2020 Tekton Authors LLC
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
		name:      "config-leader-election-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		name:      "config-leader-election-events"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		name:      "config-leader-election-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		name:      "config-logging"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
	data: {
		"zap-logger-config": """
			{
			  \"level\": \"info\",
			  \"development\": false,
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
		"loglevel.controller": "info"
		"loglevel.webhook":    "info"
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
		name:      "config-observability"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		# Note: Using Stackdriver will incur additional charges.
		metrics.backend-destination: prometheus

		# metrics.stackdriver-project-id field specifies the Stackdriver project ID. This
		# field is optional. When running on GCE, application default credentials will be
		# used and metrics will be sent to the cluster's project if this field is
		# not provided.
		metrics.stackdriver-project-id: \"<your stackdriver project id>\"

		# metrics.allow-stackdriver-custom-metrics indicates whether it is allowed
		# to send metrics to Stackdriver using \"global\" resource type and custom
		# metric type. Setting this flag to \"true\" could cause extra Stackdriver
		# charge.  If metrics.backend-destination is not Stackdriver, this is
		# ignored.
		metrics.allow-stackdriver-custom-metrics: \"false\"
		metrics.taskrun.level: \"task\"
		metrics.taskrun.duration-type: \"histogram\"
		metrics.pipelinerun.level: \"pipeline\"
		metrics.pipelinerun.duration-type: \"histogram\"
		metrics.count.enable-reason: \"false\"

		"""
}, {
	// Copyright 2020 Tekton Authors LLC
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
		name:      "config-registry-cert"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
		}
	}
}, {
	// data:
	//  # Registry's self-signed certificate
	//  cert: |

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

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-spire"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		#
		# spire-trust-domain specifies the SPIRE trust domain to use.
		# spire-trust-domain: \"example.org\"
		#
		# spire-socket-path specifies the SPIRE agent socket for SPIFFE workload API.
		# spire-socket-path: \"unix:///spiffe-workload-api/spire-agent.sock\"
		#
		# spire-server-addr specifies the SPIRE server address for workload/node registration.
		# spire-server-addr: \"spire-server.spire.svc.cluster.local:8081\"
		#
		# spire-node-alias-prefix specifies the SPIRE node alias prefix to use.
		# spire-node-alias-prefix: \"/tekton-node/\"

		"""
}, {
	// Copyright 2023 The Tekton Authors
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
		name:      "config-tracing"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/instance": "default"
			"app.kubernetes.io/part-of":  "tekton-pipelines"
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
		#
		# Enable sending traces to defined endpoint by setting this to true
		enabled: \"true\"
		#
		# API endpoint to send the traces to
		# (optional): The default value is given below
		endpoint: \"http://jaeger-collector.jaeger.svc.cluster.local:14268/api/traces\"
		# (optional) Name of the k8s secret which contains basic auth credentials
		credentialsSecret: \"jaeger-creds\"

		"""
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
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			version: "v0.59.0"
		}
	}
	spec: {
		replicas: 1
		selector: matchLabels: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "controller"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "default"
				"app.kubernetes.io/version":   "v0.59.0"
				"app.kubernetes.io/part-of":   "tekton-pipelines"
				// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
				"pipeline.tekton.dev/release": "v0.59.0"
				// labels below are related to istio and should not be used for resource lookup
				app:     "tekton-pipelines-controller"
				version: "v0.59.0"
			}
			spec: {
				affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
					matchExpressions: [{
						key:      "kubernetes.io/os"
						operator: "NotIn"
						values: ["windows"]
					}]
				}]
				serviceAccountName: "tekton-pipelines-controller"
				containers: [{
					name:  "tekton-pipelines-controller"
					image: "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.59.0@sha256:8178d0e51a35be3ebb4c6f1a2ffee2b7657daaad321ebda50b4a4718037d9208"
					args: [
						"-entrypoint-image",
						"gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.59.0@sha256:d602e0be27f766ae86949b485f9d5045b86f63f5c9ef0a6fe9d8a10283cd4aad",
						"-nop-image",
						"gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/nop:v0.59.0@sha256:6eb172889e7f8978d990b9cf7f71daeb8db9a9f7b51b8163cd8a482df8fd47c5",
						"-sidecarlogresults-image",
						"gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/sidecarlogresults:v0.59.0@sha256:52e3a25f57fcb2d59c3a4392118c6a22e0f66dca79423e2054f00919f80f77b2",
						"-workingdirinit-image",
						"gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/workingdirinit:v0.59.0@sha256:5162b2607b98ea965610dda729991f6e573670adabf86195af34a5dea5de1418",
						"-shell-image",
						"cgr.dev/chainguard/busybox@sha256:19f02276bf8dbdd62f069b922f10c65262cc34b710eea26ff928129a736be791",
						"-shell-image-win",
						"mcr.microsoft.com/powershell:nanoserver@sha256:b6d5ff841b78bdf2dfed7550000fd4f3437385b8fa686ec0f010be24777654d6",
					]
					// These images are built on-demand by `ko resolve` and are replaced
					// by image references by digest.
					// The shell image must allow root in order to create directories and copy files to PVCs.
					// cgr.dev/chainguard/busybox as of April 14 2022
					// image shall not contains tag, so it will be supported on a runtime like cri-o
					// for script mode to work with windows we need a powershell image
					// pinning to nanoserver tag as of July 15 2021
					volumeMounts: [{
						name:      "config-logging"
						mountPath: "/etc/config-logging"
					}, {
						name:      "config-registry-cert"
						mountPath: "/etc/config-registry-cert"
					}]
					env: [{
						name: "SYSTEM_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}, {
						// If you are changing these names, you will also need to update
						// the controller's Role in 200-role.yaml to include the new
						// values in the "configmaps" "get" rule.
						name:  "CONFIG_DEFAULTS_NAME"
						value: "config-defaults"
					}, {
						name:  "CONFIG_LOGGING_NAME"
						value: "config-logging"
					}, {
						name:  "CONFIG_OBSERVABILITY_NAME"
						value: "config-observability"
					}, {
						name:  "CONFIG_FEATURE_FLAGS_NAME"
						value: "feature-flags"
					}, {
						name:  "CONFIG_LEADERELECTION_NAME"
						value: "config-leader-election-controller"
					}, {
						name:  "CONFIG_SPIRE"
						value: "config-spire"
					}, {
						name:  "SSL_CERT_FILE"
						value: "/etc/config-registry-cert/cert"
					}, {
						name:  "SSL_CERT_DIR"
						value: "/etc/ssl/certs"
					}, {
						name:  "METRICS_DOMAIN"
						value: "tekton.dev/pipeline"
					}]
					securityContext: {
						allowPrivilegeEscalation: false
						capabilities: drop: ["ALL"]
						// User 65532 is the nonroot user ID
						runAsUser:    65532
						runAsGroup:   65532
						runAsNonRoot: true
						seccompProfile: type: "RuntimeDefault"
					}
					ports: [{
						name:          "metrics"
						containerPort: 9090
					}, {
						name:          "profiling"
						containerPort: 8008
					}, {
						name:          "probes"
						containerPort: 8080
					}]
					livenessProbe: {
						httpGet: {
							path:   "/health"
							port:   "probes"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						periodSeconds:       10
						timeoutSeconds:      5
					}
					readinessProbe: {
						httpGet: {
							path:   "/readiness"
							port:   "probes"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						periodSeconds:       10
						timeoutSeconds:      5
					}
				}]
				volumes: [{
					name: "config-logging"
					configMap: name: "config-logging"
				}, {
					name: "config-registry-cert"
					configMap: name: "config-registry-cert"
				}]
			}
		}
	}
}, {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			app:     "tekton-pipelines-controller"
			version: "v0.59.0"
		}
		name:      "tekton-pipelines-controller"
		namespace: "tekton-pipelines"
	}
	spec: {
		ports: [{
			name:       "http-metrics"
			port:       9090
			protocol:   "TCP"
			targetPort: 9090
		}, {
			name:       "http-profiling"
			port:       8008
			targetPort: 8008
		}, {
			name: "probes"
			port: 8080
		}]
		selector: {
			"app.kubernetes.io/name":      "controller"
			"app.kubernetes.io/component": "controller"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
}, {
	// Copyright 2023 The Tekton Authors
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
		name:      "tekton-events-controller"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "events"
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			version: "v0.59.0"
		}
	}
	spec: {
		replicas: 1
		selector: matchLabels: {
			"app.kubernetes.io/name":      "events"
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "events"
				"app.kubernetes.io/component": "events"
				"app.kubernetes.io/instance":  "default"
				"app.kubernetes.io/version":   "v0.59.0"
				"app.kubernetes.io/part-of":   "tekton-pipelines"
				// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
				"pipeline.tekton.dev/release": "v0.59.0"
				// labels below are related to istio and should not be used for resource lookup
				app:     "tekton-events-controller"
				version: "v0.59.0"
			}
			spec: {
				affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
					matchExpressions: [{
						key:      "kubernetes.io/os"
						operator: "NotIn"
						values: ["windows"]
					}]
				}]
				serviceAccountName: "tekton-events-controller"
				containers: [{
					name:  "tekton-events-controller"
					image: "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/events:v0.59.0@sha256:280022e1d3b7a80d9b4d14f3f1104e0f36772e2d9125970c4913f35a1c7c31d3"
					args: []
					volumeMounts: [{
						name:      "config-logging"
						mountPath: "/etc/config-logging"
					}, {
						name:      "config-registry-cert"
						mountPath: "/etc/config-registry-cert"
					}]
					env: [{
						name: "SYSTEM_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}, {
						// If you are changing these names, you will also need to update
						// the controller's Role in 200-role.yaml to include the new
						// values in the "configmaps" "get" rule.
						name:  "CONFIG_DEFAULTS_NAME"
						value: "config-defaults"
					}, {
						name:  "CONFIG_LOGGING_NAME"
						value: "config-logging"
					}, {
						name:  "CONFIG_OBSERVABILITY_NAME"
						value: "config-observability"
					}, {
						name:  "CONFIG_LEADERELECTION_NAME"
						value: "config-leader-election-events"
					}, {
						name:  "SSL_CERT_FILE"
						value: "/etc/config-registry-cert/cert"
					}, {
						name:  "SSL_CERT_DIR"
						value: "/etc/ssl/certs"
					}]
					securityContext: {
						allowPrivilegeEscalation: false
						capabilities: drop: ["ALL"]
						// User 65532 is the nonroot user ID
						runAsUser:    65532
						runAsGroup:   65532
						runAsNonRoot: true
						seccompProfile: type: "RuntimeDefault"
					}
					ports: [{
						name:          "metrics"
						containerPort: 9090
					}, {
						name:          "profiling"
						containerPort: 8008
					}, {
						name:          "probes"
						containerPort: 8080
					}]
					livenessProbe: {
						httpGet: {
							path:   "/health"
							port:   "probes"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						periodSeconds:       10
						timeoutSeconds:      5
					}
					readinessProbe: {
						httpGet: {
							path:   "/readiness"
							port:   "probes"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						periodSeconds:       10
						timeoutSeconds:      5
					}
				}]
				volumes: [{
					name: "config-logging"
					configMap: name: "config-logging"
				}, {
					name: "config-registry-cert"
					configMap: name: "config-registry-cert"
				}]
			}
		}
	}
}, {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			"app.kubernetes.io/name":      "events"
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			app:     "tekton-events-controller"
			version: "v0.59.0"
		}
		name:      "tekton-events-controller"
		namespace: "tekton-pipelines"
	}
	spec: {
		ports: [{
			name:       "http-metrics"
			port:       9090
			protocol:   "TCP"
			targetPort: 9090
		}, {
			name:       "http-profiling"
			port:       8008
			targetPort: 8008
		}, {
			name: "probes"
			port: 8080
		}]
		selector: {
			"app.kubernetes.io/name":      "events"
			"app.kubernetes.io/component": "events"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
}, {
	// Copyright 2022 The Tekton Authors
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
	kind:       "Namespace"
	metadata: {
		name: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component":        "resolvers"
			"app.kubernetes.io/instance":         "default"
			"app.kubernetes.io/part-of":          "tekton-pipelines"
			"pod-security.kubernetes.io/enforce": "restricted"
		}
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

	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		// ClusterRole for resolvers to monitor and update resolutionrequests.
		name: "tekton-pipelines-resolvers-resolution-request-updates"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		apiGroups: ["resolution.tekton.dev"]
		resources: ["resolutionrequests", "resolutionrequests/status"]
		verbs: ["get", "list", "watch", "update", "patch"]
	}, {
		apiGroups: ["tekton.dev"]
		resources: ["tasks", "pipelines"]
		verbs: ["get", "list"]
	}, {
		// Read-only access to these.
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["get", "list", "watch"]
	}]
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

	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: {
		name:      "tekton-pipelines-resolvers-namespace-rbac"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	rules: [{
		// Needed to watch and load configuration and secret data.
		apiGroups: [""]
		resources: ["configmaps", "secrets"]
		verbs: ["get", "list", "update", "watch"]
	}, {
		// This is needed by leader election to run the controller in HA.
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
	}]
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

	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      "tekton-pipelines-resolvers"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
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

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-resolvers"
		namespace: "tekton-pipelines-resolvers"
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "tekton-pipelines-resolvers-resolution-request-updates"
		apiGroup: "rbac.authorization.k8s.io"
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

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "tekton-pipelines-resolvers-namespace-rbac"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "tekton-pipelines-resolvers"
		namespace: "tekton-pipelines-resolvers"
	}]
	roleRef: {
		kind:     "Role"
		name:     "tekton-pipelines-resolvers-namespace-rbac"
		apiGroup: "rbac.authorization.k8s.io"
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

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "bundleresolver-config"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		// The default layer kind in the bundle image.
		"default-kind": "task"
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

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "cluster-resolver-config"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		// The default kind to fetch.
		"default-kind": "task"
		// The default namespace to look for resources in.
		"default-namespace": ""
		// An optional comma-separated list of namespaces which the resolver is allowed to access. Defaults to empty, meaning all namespaces are allowed.
		"allowed-namespaces": ""
		// An optional comma-separated list of namespaces which the resolver is blocked from accessing. Defaults to empty, meaning all namespaces are allowed.
		"blocked-namespaces": ""
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
		name:      "resolvers-feature-flags"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		// Setting this flag to "true" enables remote resolution of Tekton OCI bundles.
		"enable-bundles-resolver": "true"
		// Setting this flag to "true" enables remote resolution of tasks and pipelines via the Tekton Hub.
		"enable-hub-resolver": "true"
		// Setting this flag to "true" enables remote resolution of tasks and pipelines from Git repositories.
		"enable-git-resolver": "true"
		// Setting this flag to "true" enables remote resolution of tasks and pipelines from other namespaces within the cluster.
		"enable-cluster-resolver": "true"
	}
}, {
	// Copyright 2020 Tekton Authors LLC
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
		name:      "config-leader-election-resolvers"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
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
		name:      "config-logging"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		"zap-logger-config": """
			{
			  \"level\": \"info\",
			  \"development\": false,
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
		"loglevel.controller": "info"
		"loglevel.webhook":    "info"
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

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "config-observability"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
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

		# metrics.request-metrics-backend-destination specifies the request metrics
		# destination. If non-empty, it enables queue proxy to send request metrics.
		# Currently supported values: prometheus, stackdriver.
		metrics.request-metrics-backend-destination: prometheus

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

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "git-resolver-config"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		// The maximum amount of time a single anonymous cloning resolution may take.
		"fetch-timeout": "1m"
		// The git url to fetch the remote resource from when using anonymous cloning.
		"default-url": "https://github.com/tektoncd/catalog.git"
		// The git revision to fetch the remote resource from with either anonymous cloning or the authenticated API.
		"default-revision": "main"
		// The SCM type to use with the authenticated API. Can be github, gitlab, gitea, bitbucketserver, bitbucketcloud
		"scm-type": "github"
		// The SCM server URL to use with the authenticated API. Not needed when using github.com, gitlab.com, or BitBucket Cloud
		"server-url": ""
		// The Kubernetes secret containing the API token for the SCM provider. Required when using the authenticated API.
		"api-token-secret-name": ""
		// The key in the API token secret containing the actual token. Required when using the authenticated API.
		"api-token-secret-key": ""
		// The namespace containing the API token secret. Defaults to "default".
		"api-token-secret-namespace": "default"
		// The default organization to look for repositories under when using the authenticated API,
		// if not specified in the resolver parameters. Optional.
		"default-org": ""
	}
}, {
	// Copyright 2023 The Tekton Authors
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
		name:      "http-resolver-config"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		// The maximum amount of time the http resolver will wait for a response from the server.
		"fetch-timeout": "1m"
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

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "hubresolver-config"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
	data: {
		// the default Tekton Hub catalog from where to pull the resource.
		"default-tekton-hub-catalog": "Tekton"
		// the default Artifact Hub Task catalog from where to pull the resource.
		"default-artifact-hub-task-catalog": "tekton-catalog-tasks"
		// the default Artifact Hub Pipeline catalog from where to pull the resource.
		"default-artifact-hub-pipeline-catalog": "tekton-catalog-pipelines"
		// the default layer kind in the hub image.
		"default-kind": "task"
		// the default hub source to pull the resource from.
		"default-type": "artifact"
	}
}, {
	// Copyright 2022 The Tekton Authors
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
		name:      "tekton-pipelines-remote-resolvers"
		namespace: "tekton-pipelines-resolvers"
		labels: {
			"app.kubernetes.io/name":      "resolvers"
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			version: "v0.59.0"
		}
	}
	spec: {
		replicas: 1
		selector: matchLabels: {
			"app.kubernetes.io/name":      "resolvers"
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "resolvers"
				"app.kubernetes.io/component": "resolvers"
				"app.kubernetes.io/instance":  "default"
				"app.kubernetes.io/version":   "v0.59.0"
				"app.kubernetes.io/part-of":   "tekton-pipelines"
				// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
				"pipeline.tekton.dev/release": "v0.59.0"
				// labels below are related to istio and should not be used for resource lookup
				app:     "tekton-pipelines-resolvers"
				version: "v0.59.0"
			}
			spec: {
				affinity: podAntiAffinity: preferredDuringSchedulingIgnoredDuringExecution: [{
					podAffinityTerm: {
						labelSelector: matchLabels: {
							"app.kubernetes.io/name":      "resolvers"
							"app.kubernetes.io/component": "resolvers"
							"app.kubernetes.io/instance":  "default"
							"app.kubernetes.io/part-of":   "tekton-pipelines"
						}
						topologyKey: "kubernetes.io/hostname"
					}
					weight: 100
				}]
				serviceAccountName: "tekton-pipelines-resolvers"
				containers: [{
					name:  "controller"
					image: "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/resolvers:v0.59.0@sha256:80015cd2b4bb73ea894733eec96befcf2e61670017cf579f4cd75a393ae7dd41"
					resources: {
						requests: {
							cpu:    "100m"
							memory: "100Mi"
						}
						limits: {
							cpu:    "1000m"
							memory: "4Gi"
						}
					}
					ports: [{
						name:          "metrics"
						containerPort: 9090
					}, {
						name:          "profiling"
						containerPort: 8008
					}, {
						// This must match the value of the environment variable PROBES_PORT.
						name:          "probes"
						containerPort: 8080
					}]
					env: [{
						name: "SYSTEM_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}, {
						// If you are changing these names, you will also need to update
						// the controller's Role in 200-role.yaml to include the new
						// values in the "configmaps" "get" rule.
						name:  "CONFIG_LOGGING_NAME"
						value: "config-logging"
					}, {
						name:  "CONFIG_OBSERVABILITY_NAME"
						value: "config-observability"
					}, {
						name:  "CONFIG_FEATURE_FLAGS_NAME"
						value: "feature-flags"
					}, {
						name:  "CONFIG_LEADERELECTION_NAME"
						value: "config-leader-election-resolvers"
					}, {
						name:  "METRICS_DOMAIN"
						value: "tekton.dev/resolution"
					}, {
						name:  "PROBES_PORT"
						value: "8080"
					}, {
						// Override this env var to set a private hub api endpoint
						name:  "ARTIFACT_HUB_API"
						value: "https://artifacthub.io/"
					}, {
						name:  "TEKTON_HUB_API"
						value: "https://api.hub.tekton.dev/"
					}]
					securityContext: {
						allowPrivilegeEscalation: false
						readOnlyRootFilesystem:   true
						runAsNonRoot:             true
						capabilities: drop: ["ALL"]
						seccompProfile: type: "RuntimeDefault"
					}
				}]
			}
		}
	}
}, {
	// Copyright 2023 The Tekton Authors
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
		labels: {
			"app.kubernetes.io/name":      "resolvers"
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			app:     "tekton-pipelines-remote-resolvers"
			version: "v0.59.0"
		}
		name:      "tekton-pipelines-remote-resolvers"
		namespace: "tekton-pipelines-resolvers"
	}
	spec: {
		ports: [{
			name:       "http-metrics"
			port:       9090
			protocol:   "TCP"
			targetPort: 9090
		}, {
			name:       "http-profiling"
			port:       8008
			targetPort: 8008
		}, {
			name: "probes"
			port: 8080
		}]
		selector: {
			"app.kubernetes.io/name":      "resolvers"
			"app.kubernetes.io/component": "resolvers"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
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

	apiVersion: "autoscaling/v2"
	kind:       "HorizontalPodAutoscaler"
	metadata: {
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			version: "v0.59.0"
		}
	}
	spec: {
		minReplicas: 1
		maxReplicas: 5
		scaleTargetRef: {
			apiVersion: "apps/v1"
			kind:       "Deployment"
			name:       "tekton-pipelines-webhook"
		}
		metrics: [{
			type: "Resource"
			resource: {
				name: "cpu"
				target: {
					type:               "Utilization"
					averageUtilization: 100
				}
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

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		// Note: the Deployment name must be the same as the Service name specified in
		// config/400-webhook-service.yaml. If you change this name, you must also
		// change the value of WEBHOOK_SERVICE_NAME below.
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
		labels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			version: "v0.59.0"
		}
	}
	spec: {
		selector: matchLabels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "webhook"
				"app.kubernetes.io/component": "webhook"
				"app.kubernetes.io/instance":  "default"
				"app.kubernetes.io/version":   "v0.59.0"
				"app.kubernetes.io/part-of":   "tekton-pipelines"
				// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
				"pipeline.tekton.dev/release": "v0.59.0"
				// labels below are related to istio and should not be used for resource lookup
				app:     "tekton-pipelines-webhook"
				version: "v0.59.0"
			}
			spec: {
				affinity: {
					nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
						matchExpressions: [{
							key:      "kubernetes.io/os"
							operator: "NotIn"
							values: ["windows"]
						}]
					}]
					podAntiAffinity: preferredDuringSchedulingIgnoredDuringExecution: [{
						podAffinityTerm: {
							labelSelector: matchLabels: {
								"app.kubernetes.io/name":      "webhook"
								"app.kubernetes.io/component": "webhook"
								"app.kubernetes.io/instance":  "default"
								"app.kubernetes.io/part-of":   "tekton-pipelines"
							}
							topologyKey: "kubernetes.io/hostname"
						}
						weight: 100
					}]
				}
				serviceAccountName: "tekton-pipelines-webhook"
				containers: [{
					name: "webhook"
					// This is the Go import path for the binary that is containerized
					// and substituted here.
					image: "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.59.0@sha256:43115883a5b0621e86358d3598e464e7a9192c8e92878ce5a9c4f193a5b679c1"
					// Resource request required for autoscaler to take any action for a metric
					resources: {
						requests: {
							cpu:    "100m"
							memory: "100Mi"
						}
						limits: {
							cpu:    "500m"
							memory: "500Mi"
						}
					}
					env: [{
						name: "SYSTEM_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}, {
						// If you are changing these names, you will also need to update
						// the webhook's Role in 200-role.yaml to include the new
						// values in the "configmaps" "get" rule.
						name:  "CONFIG_LOGGING_NAME"
						value: "config-logging"
					}, {
						name:  "CONFIG_OBSERVABILITY_NAME"
						value: "config-observability"
					}, {
						name:  "CONFIG_LEADERELECTION_NAME"
						value: "config-leader-election-webhook"
					}, {
						name:  "CONFIG_FEATURE_FLAGS_NAME"
						value: "feature-flags"
					}, {
						// If you change PROBES_PORT, you will also need to change the
						// containerPort "probes" to the same value.
						name:  "PROBES_PORT"
						value: "8080"
					}, {
						// If you change WEBHOOK_PORT, you will also need to change the
						// containerPort "https-webhook" to the same value.
						name:  "WEBHOOK_PORT"
						value: "8443"
					}, {
						// if you change WEBHOOK_ADMISSION_CONTROLLER_NAME, you will also need to update
						// the webhooks.name in 500-webhooks.yaml to include the new names of admission webhooks.
						// Additionally, you will also need to change the resource names (metadata.name) of
						// "MutatingWebhookConfiguration" and "ValidatingWebhookConfiguration" in 500-webhooks.yaml
						// to reflect the change in the name of the admission webhook.
						// Followed by changing the webhook's Role in 200-clusterrole.yaml to update the "resourceNames" of
						// "mutatingwebhookconfigurations" and "validatingwebhookconfigurations" resources.
						name:  "WEBHOOK_ADMISSION_CONTROLLER_NAME"
						value: "webhook.pipeline.tekton.dev"
					}, {
						name:  "WEBHOOK_SERVICE_NAME"
						value: "tekton-pipelines-webhook"
					}, {
						name:  "WEBHOOK_SECRET_NAME"
						value: "webhook-certs"
					}, {
						name:  "METRICS_DOMAIN"
						value: "tekton.dev/pipeline"
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
					ports: [{
						name:          "metrics"
						containerPort: 9090
					}, {
						name:          "profiling"
						containerPort: 8008
					}, {
						// This must match the value of the environment variable WEBHOOK_PORT.
						name:          "https-webhook"
						containerPort: 8443
					}, {
						// This must match the value of the environment variable PROBES_PORT.
						name:          "probes"
						containerPort: 8080
					}]
					livenessProbe: {
						httpGet: {
							path:   "/health"
							port:   "probes"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						periodSeconds:       10
						timeoutSeconds:      5
					}
					readinessProbe: {
						httpGet: {
							path:   "/readiness"
							port:   "probes"
							scheme: "HTTP"
						}
						initialDelaySeconds: 5
						periodSeconds:       10
						timeoutSeconds:      5
					}
				}]
			}
		}
	}
}, {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/version":   "v0.59.0"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
			// tekton.dev/release value replaced with inputs.params.versionTag in pipeline/tekton/publish.yaml
			"pipeline.tekton.dev/release": "v0.59.0"
			// labels below are related to istio and should not be used for resource lookup
			app:     "tekton-pipelines-webhook"
			version: "v0.59.0"
		}
		name:      "tekton-pipelines-webhook"
		namespace: "tekton-pipelines"
	}
	spec: {
		ports: [{
			// Define metrics and profiling for them to be accessible within service meshes.
			name:       "http-metrics"
			port:       9090
			targetPort: "metrics"
		}, {
			name:       "http-profiling"
			port:       8008
			targetPort: "profiling"
		}, {
			name:       "https-webhook"
			port:       443
			targetPort: "https-webhook"
		}, {
			name:       "probes"
			port:       8080
			targetPort: "probes"
		}]
		selector: {
			"app.kubernetes.io/name":      "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "default"
			"app.kubernetes.io/part-of":   "tekton-pipelines"
		}
	}
}]
