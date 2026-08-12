import 'dart:async';

import 'package:my_app/services/api_service.dart';
import 'package:my_app/core/models/form_payload.dart';
import 'package:my_app/core/utils/metadata_helper.dart';

Future<void> main() async {
  print('--- Demo Runner: DigiVir Verification (headless) ---');

  final api = ApiService();

  // Case 1: Valid submission (first request in session)
  print('\n[Case 1] Valid submission (first request)');
  MetadataHelper.resetChain();
  MetadataHelper.forceInvalidPredecessorForDemo = false;

  final payload1 = FormPayload(
    fullName: 'Alice Example',
    email: 'alice@example.com',
    phone: '+12345678901',
    profileCategory: 'Learning Support Assistant',
    notes: 'Demo case 1 - valid',
  );

  final r1 = await api.submitVerificationForm(payload1);
  print('Result: success=${r1.success}, isFailClosed=${r1.isFailClosed}');
  print(' Message: ${r1.message}');
  print(' trace_id: ${r1.traceId}');
  print(' logic_hash: ${r1.logicHash}');
  print(' predecessor_id: ${r1.predecessorId}');
  if (r1.responseData != null) print(' Response keys: ${r1.responseData!.keys}\n');

  // Small pause to separate logs
  await Future.delayed(const Duration(milliseconds: 250));

  // Case 2: Missing Lineage — force an invalid predecessor to trigger Gate 2
  print('\n[Case 2] Missing Lineage (force invalid predecessor)');
  MetadataHelper.forceInvalidPredecessorForDemo = true;

  final payload2 = payload1.copyWith(notes: 'Demo case 2 - missing lineage');
  final r2 = await api.submitVerificationForm(payload2);
  print('Result: success=${r2.success}, isFailClosed=${r2.isFailClosed}');
  print(' failClosedGate: ${r2.failClosedGate}');
  print(' predecessor_id used: ${r2.predecessorId}');
  print(' Message: ${r2.message}\n');

  await Future.delayed(const Duration(milliseconds: 250));

  // Case 3: Fail-Closed Error State — missing required fields (Gate 1)
  print('\n[Case 3] Fail-Closed Error State (missing required fields)');
  MetadataHelper.forceInvalidPredecessorForDemo = false;

  final payload3 = FormPayload(
    fullName: null,
    email: 'not-an-email',
    phone: null,
    profileCategory: null,
    notes: null,
  );

  final r3 = await api.submitVerificationForm(payload3);
  print('Result: success=${r3.success}, isFailClosed=${r3.isFailClosed}');
  print(' failClosedGate: ${r3.failClosedGate}');
  print(' Message: ${r3.message}\n');

  print('--- Demo Runner Complete ---');
}
