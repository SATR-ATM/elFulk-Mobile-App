import 'package:dio/dio.dart';

import 'package:elfulk/src/core/networking/app/app_api_constants.dart';
import 'package:elfulk/src/core/networking/child/child_api_constants.dart';
import 'package:elfulk/src/core/networking/parent/parent_api_constants.dart';

class DummyApiInterceptor extends Interceptor {
  DummyApiInterceptor();

  final List<Map<String, dynamic>> _parentRequests = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'req_001',
      'child_name': 'Youssef',
      'request_type': 'Screen time extension',
      'status': 'pending',
      'requested_at': '2026-03-18 08:30',
      'note': 'Needs 30 extra minutes to finish a math challenge.',
    },
    <String, dynamic>{
      'id': 'req_002',
      'child_name': 'Salma',
      'request_type': 'Weekly allowance release',
      'status': 'approved',
      'requested_at': '2026-03-17 18:10',
      'note': 'Approved in the dummy layer to show a completed PATCH result.',
    },
    <String, dynamic>{
      'id': 'req_003',
      'child_name': 'Amir',
      'request_type': 'Homework unlock',
      'status': 'pending',
      'requested_at': '2026-03-17 16:45',
      'note': 'Waiting for a parent decision before the next lesson opens.',
    },
  ];
  int _requestSeed = 3;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    try {
      final Response<dynamic>? response = _responseForRequest(options);
      if (response != null) {
        handler.resolve(response);
        return;
      }
    } on DioException catch (error) {
      handler.reject(error);
      return;
    }

    handler.reject(
      DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 404,
          data: <String, dynamic>{
            'detail': 'No dummy response is configured for ${options.uri.path}',
          },
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }

  Response<dynamic>? _responseForRequest(RequestOptions options) {
    final String path = options.uri.path;
    final String method = options.method.toUpperCase();

    if (method == 'GET' && path == AppApiConstants.homeOverview) {
      return _jsonResponse(options, _appHomePayload(options));
    }
    if (method == 'GET' && path == ParentApiConstants.homeOverview) {
      return _jsonResponse(options, _parentHomePayload(options));
    }
    if (method == 'GET' && path == ParentApiConstants.requestsOverview) {
      return _jsonResponse(options, _parentRequestsPayload(options));
    }
    if (method == 'POST' && path == ParentApiConstants.requestsOverview) {
      return _createParentRequest(options);
    }
    if (method == 'PATCH' &&
        path.startsWith('${ParentApiConstants.requestsOverview}/')) {
      return _updateParentRequest(options);
    }
    if (method == 'GET' && path == ChildApiConstants.homeOverview) {
      return _jsonResponse(options, _childHomePayload(options));
    }
    if (method == 'POST' && path == AppApiConstants.login) {
      return _jsonResponse(options, <String, dynamic>{
        'token': 'dummy_token_12345',
        'userName': 'Nasreddine',
        'email': 'nas@elfulk.ai',
      });
    }
    if (method == 'POST' && path == AppApiConstants.register) {
      return _jsonResponse(options, <String, dynamic>{
        'token': 'dummy_token_register_67890',
        'userName': 'New User',
        'email': 'new@elfulk.ai',
      });
    }

    return null;
  }

  Map<String, dynamic> _appHomePayload(RequestOptions options) {
    return <String, dynamic>{
      'headline': 'ElFulk app_features example',
      'summary':
          'This screen is loaded through a Retrofit API service, typed response model, repository, Cubit, and dummy Dio response so the same stack stays active during development.',
      'base_url': options.uri.origin,
      'endpoint': AppApiConstants.homeOverview,
      'principles': <String>[
        'GetIt composition root',
        'GoRouter page builders',
        'Cubit plus Freezed states',
        'Retrofit API services',
        'JsonSerializable DTO models',
        'ApiResult error normalization',
      ],
      'modules': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'app_features',
          'description':
              'Shared app shell, architecture docs, and entry workflows.',
          'status': 'Ready',
          'folders': <String>[
            'lib/src/features/app_features/home/',
            'lib/src/features/app_features/architecture/',
          ],
          'next_step': 'Add onboarding, authentication, and settings here.',
        },
        <String, dynamic>{
          'name': 'parent_features',
          'description':
              'Example parent-facing modules with their own models, repos, Cubits, and Blocs.',
          'status': 'Ready',
          'folders': <String>[
            'lib/src/features/parent_features/parent_home/',
            'lib/src/features/parent_features/parent_requests/',
          ],
          'next_step':
              'Use this group for parent dashboards, approvals, and request workflows.',
        },
        <String, dynamic>{
          'name': 'child_features',
          'description':
              'Example child-facing modules with their own routing and dummy endpoints.',
          'status': 'Ready',
          'folders': <String>['lib/src/features/child_features/child_home/'],
          'next_step':
              'Use this group for child activity, tasks, and progress.',
        },
      ],
      'next_milestones': <String>[
        'Replace the dummy interceptor with real APIs while keeping the same repository and Cubit or Bloc contracts.',
        'Keep request models with @JsonSerializable(createFactory: false) for POST and PATCH endpoints.',
        'Use Bloc for parent or child flows that coordinate multiple events and write operations.',
      ],
    };
  }

  Map<String, dynamic> _parentHomePayload(RequestOptions options) {
    return <String, dynamic>{
      'title': 'Parent feature example',
      'summary':
          'This dummy response represents the parent side of the app with cards, next actions, and endpoint metadata.',
      'base_url': options.uri.origin,
      'endpoint': ParentApiConstants.homeOverview,
      'highlights': <Map<String, dynamic>>[
        <String, dynamic>{
          'label': 'Linked children',
          'value': '3',
          'detail':
              'Returned by ParentApiService from the dummy networking layer.',
        },
        <String, dynamic>{
          'label': 'Unread approvals',
          'value': '5',
          'detail': 'Use this pattern for moderation or permission requests.',
        },
        <String, dynamic>{
          'label': 'Bloc demo route',
          'value': 'Ready',
          'detail':
              'Open the parent requests screen to see GET, POST, and PATCH flows together.',
        },
      ],
      'next_actions': <String>[
        'Review child activity summaries.',
        'Approve the next pending request.',
        'Open the Bloc-based parent requests flow for event-heavy interactions.',
      ],
    };
  }

  Map<String, dynamic> _parentRequestsPayload(RequestOptions options) {
    return <String, dynamic>{
      'title': 'Parent requests Bloc example',
      'summary':
          'This feature uses Bloc because it coordinates an initial GET, a POST create action, PATCH status updates, and UI feedback in one event stream.',
      'base_url': options.uri.origin,
      'endpoint': ParentApiConstants.requestsOverview,
      'post_endpoint': ParentApiConstants.requestsOverview,
      'patch_endpoint_template': ParentApiConstants.requestDetails,
      'recommended_events': <String>[
        'loadData() fetches the initial list through ParentApiService.',
        'createRequest(CreateParentRequestModel) simulates a POST write flow.',
        'updateRequestStatus(requestId, PatchParentRequestStatusModel) simulates a PATCH write flow.',
        'clearFeedback() resets the transient mutation message without reloading the whole screen.',
      ],
      'requests': _parentRequests,
    };
  }

  Map<String, dynamic> _childHomePayload(RequestOptions options) {
    return <String, dynamic>{
      'title': 'Child feature example',
      'summary':
          'This dummy response represents the child side of the app with tasks, streaks, and a dedicated endpoint.',
      'base_url': options.uri.origin,
      'endpoint': ChildApiConstants.homeOverview,
      'tasks': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Read today lesson',
          'status': 'completed',
          'reward': '15 pts',
        },
        <String, dynamic>{
          'title': 'Submit homework photo',
          'status': 'pending',
          'reward': '20 pts',
        },
        <String, dynamic>{
          'title': 'Practice vocabulary',
          'status': 'in-progress',
          'reward': '10 pts',
        },
      ],
      'tips': <String>[
        'Keep child_features focused on child-facing flows only.',
        'Reuse app_features for shared settings and notifications.',
        'Promote common widgets to core only after repetition appears.',
      ],
    };
  }

  Response<dynamic> _createParentRequest(RequestOptions options) {
    final Map<String, dynamic> payload = _readBody(options);
    final String childName = payload['child_name']?.toString().trim() ?? '';
    final String requestType = payload['request_type']?.toString().trim() ?? '';
    final String note = payload['note']?.toString().trim() ?? '';

    if (childName.isEmpty || requestType.isEmpty || note.isEmpty) {
      throw _badResponse(
        options,
        statusCode: 400,
        detail: 'child_name, request_type, and note are required.',
      );
    }

    _requestSeed += 1;
    final Map<String, dynamic> request = <String, dynamic>{
      'id': 'req_${_requestSeed.toString().padLeft(3, '0')}',
      'child_name': childName,
      'request_type': requestType,
      'status': 'pending',
      'requested_at':
          '2026-03-18 12:${(10 + _requestSeed).toString().padLeft(2, '0')}',
      'note': note,
    };

    _parentRequests.insert(0, request);
    return _jsonResponse(options, request, statusCode: 201);
  }

  Response<dynamic> _updateParentRequest(RequestOptions options) {
    final String requestId = options.uri.pathSegments.last;
    final int requestIndex = _parentRequests.indexWhere(
      (Map<String, dynamic> request) => request['id'] == requestId,
    );
    if (requestIndex == -1) {
      throw _badResponse(
        options,
        statusCode: 404,
        detail: 'No parent request exists for $requestId.',
      );
    }

    final Map<String, dynamic> payload = _readBody(options);
    final String status = payload['status']?.toString().trim() ?? '';
    final String reviewNote = payload['review_note']?.toString().trim() ?? '';
    if (status.isEmpty) {
      throw _badResponse(
        options,
        statusCode: 400,
        detail: 'status is required for request updates.',
      );
    }

    final Map<String, dynamic> updatedRequest = <String, dynamic>{
      ..._parentRequests[requestIndex],
      'status': status,
      'note': reviewNote.isEmpty
          ? _parentRequests[requestIndex]['note']
          : reviewNote,
    };
    _parentRequests[requestIndex] = updatedRequest;

    return _jsonResponse(options, updatedRequest);
  }

  Map<String, dynamic> _readBody(RequestOptions options) {
    final Object? data = options.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  Response<dynamic> _jsonResponse(
    RequestOptions options,
    Object? data, {
    int statusCode = 200,
  }) {
    return Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    );
  }

  DioException _badResponse(
    RequestOptions options, {
    required int statusCode,
    required String detail,
  }) {
    return DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: statusCode,
        data: <String, dynamic>{'detail': detail},
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
