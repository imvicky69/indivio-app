#!/usr/bin/env node
/**
 * INDIVIO EDTECH — FIRESTORE SEED SCRIPT
 * =======================================
 * Pushes all local mock_db JSON files to Firebase Firestore.
 *
 * Usage:
 *   node seed.js              → seeds everything
 *   node seed.js --dry-run    → shows what WOULD be seeded, writes nothing
 *   node seed.js --collection school     → seeds only school
 *   node seed.js --collection students   → seeds only students
 *   node seed.js --wipe       → deletes all seeded data then re-seeds
 *   node seed.js --verify     → reads back from Firestore and prints counts
 *
 * Collections seeded (in order):
 *   1.  schools
 *   2.  users         (from students + teachers combined)
 *   3.  students
 *   4.  teachers
 *   5.  classes
 *   6.  subjects
 *   7.  timetable
 *   8.  attendance    (nested path: attendance/SCH001/2024-11-XX/CLS_10A/STU00X)
 *   9.  homework
 *   10. assignments
 *   11. submissions   (nested inside academics.json)
 *   12. tests + results subcollection
 *   13. fees
 *   14. leaves
 *   15. announcements
 *   16. notifications (nested path: notifications/{uid}/items/{notifId})
 *   17. materials
 *   18. syllabusTracker
 */

'use strict';

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

// ─── CONFIG ──────────────────────────────────────────────────────────────────

const CONFIG = {
  serviceAccountPath: path.join(__dirname, 'serviceAccountKey.json'),
  mockDbPath: path.join(__dirname, 'mock_db'),
  schoolId: 'SCH001',
  batchSize: 490,   // Firestore batch limit is 500, stay safe
  delayBetweenBatches: 300,  // ms — avoid rate limiting
};

// ─── CLI ARGS ─────────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');
const isWipe = args.includes('--wipe');
const isVerify = args.includes('--verify');
const collectionFlag = args.indexOf('--collection');
const targetCollection = collectionFlag !== -1 ? args[collectionFlag + 1] : null;

// ─── INIT FIREBASE ────────────────────────────────────────────────────────────

function initFirebase() {
  if (!fs.existsSync(CONFIG.serviceAccountPath)) {
    console.error(chalk.red(`\n❌ serviceAccountKey.json not found at:`));
    console.error(chalk.yellow(`   ${CONFIG.serviceAccountPath}`));
    console.error(chalk.white(`\n📋 To fix:`));
    console.error(`   1. Go to Firebase Console → Project Settings → Service Accounts`);
    console.error(`   2. Click "Generate new private key"`);
    console.error(`   3. Save as serviceAccountKey.json in the same folder as seed.js\n`);
    process.exit(1);
  }

  const serviceAccount = require(CONFIG.serviceAccountPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  return admin.firestore();
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────

function loadJson(filename) {
  const filePath = path.join(CONFIG.mockDbPath, filename);
  if (!fs.existsSync(filePath)) {
    console.warn(chalk.yellow(`⚠️  File not found: ${filename} — skipping`));
    return null;
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function log(emoji, msg, color = 'white') {
  console.log(chalk[color](`${emoji}  ${msg}`));
}

function logSection(title) {
  console.log(chalk.cyan(`\n${'─'.repeat(50)}`));
  console.log(chalk.cyan.bold(`  ${title}`));
  console.log(chalk.cyan(`${'─'.repeat(50)}`));
}

// Convert ISO date strings → Firestore Timestamps
function convertDates(obj) {
  if (obj === null || obj === undefined) return obj;
  if (typeof obj === 'string') {
    // Match ISO datetime strings like "2024-11-20T07:47:00+05:30"
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(obj)) {
      return admin.firestore.Timestamp.fromDate(new Date(obj));
    }
    return obj;
  }
  if (Array.isArray(obj)) return obj.map(convertDates);
  if (typeof obj === 'object') {
    const result = {};
    for (const [k, v] of Object.entries(obj)) {
      result[k] = convertDates(v);
    }
    return result;
  }
  return obj;
}

// Remove mock-only fields that shouldn't go to Firestore
function cleanForFirestore(obj) {
  const cleaned = { ...obj };
  delete cleaned._queryKeys;   // dev-only lookup helper
  return cleaned;
}

let totalWritten = 0;
let totalSkipped = 0;

// Batch writer — handles Firestore 500-doc batch limit
async function batchWrite(db, writes) {
  if (isDryRun) {
    log('🔍', `DRY RUN — would write ${writes.length} documents`, 'yellow');
    totalWritten += writes.length;
    return;
  }

  for (let i = 0; i < writes.length; i += CONFIG.batchSize) {
    const chunk = writes.slice(i, i + CONFIG.batchSize);
    const batch = db.batch();
    for (const { ref, data } of chunk) {
      batch.set(ref, data, { merge: false });
    }
    await batch.commit();
    totalWritten += chunk.length;

    if (i + CONFIG.batchSize < writes.length) {
      await new Promise(r => setTimeout(r, CONFIG.delayBetweenBatches));
    }
  }
}

// ─── SEEDERS ──────────────────────────────────────────────────────────────────

async function seedSchool(db) {
  logSection('1. School');
  const school = loadJson('school.json');
  if (!school) return;

  const data = convertDates(cleanForFirestore(school));
  const writes = [{ ref: db.collection('schools').doc(school.schoolId), data }];

  await batchWrite(db, writes);
  log('✅', `School seeded: ${school.name} (${school.schoolId})`, 'green');
}

async function seedClasses(db) {
  logSection('2. Classes');
  const classes = loadJson('classes.json');
  if (!classes) return;

  const writes = classes.map(cls => ({
    ref: db.collection('classes').doc(cls.classId),
    data: convertDates(cleanForFirestore(cls)),
  }));

  await batchWrite(db, writes);
  log('✅', `${writes.length} classes seeded`, 'green');
}

async function seedSubjects(db) {
  logSection('3. Subjects');
  const subjects = loadJson('subjects.json');
  if (!subjects) return;

  const writes = subjects.map(sub => ({
    ref: db.collection('subjects').doc(sub.subjectId),
    data: convertDates(cleanForFirestore(sub)),
  }));

  await batchWrite(db, writes);
  log('✅', `${writes.length} subjects seeded`, 'green');
}

async function seedStudentsAndUsers(db) {
  logSection('4. Students + User accounts (students)');
  const students = loadJson('students.json');
  if (!students) return;

  const studentWrites = [];
  const userWrites = [];

  for (const student of students) {
    // Students collection — full student document without _queryKeys
    const studentData = convertDates(cleanForFirestore(student));
    // Promote _queryKeys fields to top-level for Firestore indexing
    const queryKeys = student._queryKeys || {};
    studentWrites.push({
      ref: db.collection('students').doc(student.studentId),
      data: {
        ...studentData,
        // Promote key fields to top-level for compound index queries
        userId: queryKeys.uid || '',
        admissionNumber: queryKeys.admissionNumber || '',
        srNumber: queryKeys.srNumber || '',
        rollNumber: queryKeys.rollNumber || student.academic?.rollNumber || '',
        phone: queryKeys.phone || student.contact?.phone || '',
        parentPhone: queryKeys.parentPhone || '',
      },
    });

    // Users collection — lightweight auth record
    userWrites.push({
      ref: db.collection('users').doc(queryKeys.uid),
      data: {
        uid: queryKeys.uid,
        name: student.personal.fullName,
        email: student.contact.email || '',
        phone: queryKeys.phone || '',
        role: 'student',
        schoolId: student.schoolId,
        photoUrl: student.personal.photoUrl || '',
        fcmToken: student.appAccess?.fcmToken || '',
        studentId: student.studentId,
        classId: student.academic.classId,
        createdAt: convertDates(student.createdAt),
      },
    });
  }

  await batchWrite(db, studentWrites);
  log('✅', `${studentWrites.length} students seeded`, 'green');

  await batchWrite(db, userWrites);
  log('✅', `${userWrites.length} student user accounts seeded`, 'green');
}

async function seedTeachersAndUsers(db) {
  logSection('5. Teachers + User accounts (teachers)');
  const teachers = loadJson('teachers.json');
  if (!teachers) return;

  const teacherWrites = [];
  const userWrites = [];

  for (const teacher of teachers) {
    const queryKeys = teacher._queryKeys || {};
    const teacherData = convertDates(cleanForFirestore(teacher));

    teacherWrites.push({
      ref: db.collection('teachers').doc(teacher.teacherId),
      data: {
        ...teacherData,
        userId: queryKeys.uid || '',
        employeeId: queryKeys.employeeId || '',
        phone: queryKeys.phone || '',
        email: queryKeys.email || '',
      },
    });

    userWrites.push({
      ref: db.collection('users').doc(queryKeys.uid),
      data: {
        uid: queryKeys.uid,
        name: teacher.personal.fullName,
        email: queryKeys.email || '',
        phone: queryKeys.phone || '',
        role: 'teacher',
        schoolId: teacher.schoolId,
        photoUrl: teacher.personal.photoUrl || '',
        fcmToken: teacher.appAccess?.fcmToken || '',
        teacherId: teacher.teacherId,
        employeeId: queryKeys.employeeId || '',
        createdAt: convertDates(teacher.createdAt),
      },
    });
  }

  await batchWrite(db, teacherWrites);
  log('✅', `${teacherWrites.length} teachers seeded`, 'green');

  await batchWrite(db, userWrites);
  log('✅', `${userWrites.length} teacher user accounts seeded`, 'green');
}

async function seedTimetable(db) {
  logSection('6. Timetable');
  const timetable = loadJson('timetable.json');
  if (!timetable) return;

  const writes = [{
    ref: db.collection('timetable').doc(timetable.timetableId),
    data: convertDates(cleanForFirestore(timetable)),
  }];

  await batchWrite(db, writes);
  log('✅', `Timetable seeded: ${timetable.timetableId}`, 'green');
}

async function seedAttendance(db) {
  logSection('7. Attendance');
  const attendance = loadJson('attendance.json');
  if (!attendance) return;

  const writes = [];
  const { schoolId, classId } = attendance.attendanceSummary;

  for (const dayRecord of attendance.dailyRecords) {
    if (dayRecord.isHoliday) {
      // Write holiday marker at date level
      writes.push({
        ref: db.collection('attendance')
          .doc(schoolId)
          .collection(dayRecord.date)
          .doc('_meta'),
        data: {
          isHoliday: true,
          holidayName: dayRecord.holidayName,
          date: dayRecord.date,
          schoolId,
          classId,
        },
      });
      continue;
    }

    if (!dayRecord.students) continue;

    // Write day-level summary
    writes.push({
      ref: db.collection('attendance')
        .doc(schoolId)
        .collection(dayRecord.date)
        .doc('_summary'),
      data: {
        date: dayRecord.date,
        dayName: dayRecord.dayName,
        classId,
        schoolId,
        markedBy: dayRecord.markedBy,
        markedAt: convertDates(dayRecord.markedAt),
        presentCount: dayRecord.presentCount || 0,
        absentCount: dayRecord.absentCount || 0,
        lateCount: dayRecord.lateCount || 0,
        leaveCount: dayRecord.leaveCount || 0,
      },
    });

    // Write per-student record
    for (const student of dayRecord.students) {
      writes.push({
        ref: db.collection('attendance')
          .doc(schoolId)
          .collection(dayRecord.date)
          .doc(classId)
          .collection('students')
          .doc(student.studentId),
        data: {
          studentId: student.studentId,
          status: student.status,
          remarks: student.remarks || null,
          markedBy: dayRecord.markedBy,
          markedAt: convertDates(dayRecord.markedAt),
          date: dayRecord.date,
          schoolId,
          classId,
        },
      });
    }
  }

  await batchWrite(db, writes);
  log('✅', `${writes.length} attendance records seeded`, 'green');
}

async function seedAcademics(db) {
  logSection('8. Homework');
  const academics = loadJson('academics.json');
  if (!academics) return;

  // Homework
  const hwWrites = (academics.homework || []).map(hw => ({
    ref: db.collection('homework').doc(hw.homeworkId),
    data: convertDates(cleanForFirestore(hw)),
  }));
  await batchWrite(db, hwWrites);
  log('✅', `${hwWrites.length} homework docs seeded`, 'green');

  logSection('9. Assignments + Submissions');

  const assignmentWrites = [];
  const submissionWrites = [];

  for (const assignment of (academics.assignments || [])) {
    const { submissions, ...assignmentData } = assignment;

    assignmentWrites.push({
      ref: db.collection('assignments').doc(assignment.assignmentId),
      data: convertDates(cleanForFirestore(assignmentData)),
    });

    for (const sub of (submissions || [])) {
      submissionWrites.push({
        ref: db.collection('submissions').doc(sub.submissionId),
        data: convertDates(cleanForFirestore({
          ...sub,
          schoolId: assignment.schoolId,
          classId: assignment.classId,
        })),
      });
    }
  }

  await batchWrite(db, assignmentWrites);
  log('✅', `${assignmentWrites.length} assignments seeded`, 'green');

  await batchWrite(db, submissionWrites);
  log('✅', `${submissionWrites.length} submissions seeded`, 'green');

  logSection('10. Test Results');

  const testWrites = [];
  const resultWrites = [];

  for (const test of (academics.testResults || [])) {
    const { results, ...testData } = test;

    testWrites.push({
      ref: db.collection('tests').doc(test.testId),
      data: convertDates(cleanForFirestore(testData)),
    });

    for (const result of (results || [])) {
      resultWrites.push({
        ref: db.collection('tests')
          .doc(test.testId)
          .collection('results')
          .doc(result.studentId),
        data: convertDates({
          ...result,
          testId: test.testId,
          schoolId: test.schoolId,
          classId: test.classId,
          subjectId: test.subjectId,
        }),
      });
    }
  }

  await batchWrite(db, testWrites);
  log('✅', `${testWrites.length} tests seeded`, 'green');

  await batchWrite(db, resultWrites);
  log('✅', `${resultWrites.length} test results seeded`, 'green');
}

async function seedFeesLeavesAnnouncements(db) {
  const data = loadJson('fees_leaves_announcements.json');
  if (!data) return;

  logSection('11. Fees');
  const feeWrites = (data.fees || []).map(fee => ({
    ref: db.collection('fees').doc(fee.feeId),
    data: convertDates(cleanForFirestore(fee)),
  }));
  await batchWrite(db, feeWrites);
  log('✅', `${feeWrites.length} fee records seeded`, 'green');

  logSection('12. Leaves');
  const leaveWrites = (data.leaves || []).map(leave => ({
    ref: db.collection('leaves').doc(leave.leaveId),
    data: convertDates(cleanForFirestore(leave)),
  }));
  await batchWrite(db, leaveWrites);
  log('✅', `${leaveWrites.length} leave records seeded`, 'green');

  logSection('13. Announcements');
  const noticeWrites = (data.announcements || []).map(notice => ({
    ref: db.collection('announcements').doc(notice.announcementId),
    data: convertDates(cleanForFirestore(notice)),
  }));
  await batchWrite(db, noticeWrites);
  log('✅', `${noticeWrites.length} announcements seeded`, 'green');

  logSection('14. Notifications');
  const notifWrites = (data.notifications || []).map(notif => ({
    ref: db.collection('notifications')
      .doc(notif.targetUid)
      .collection('items')
      .doc(notif.notifId),
    data: convertDates(cleanForFirestore(notif)),
  }));
  await batchWrite(db, notifWrites);
  log('✅', `${notifWrites.length} notifications seeded`, 'green');
}

async function seedMaterials(db) {
  const data = loadJson('materials_syllabus.json');
  if (!data) return;

  logSection('15. Study Materials');
  const matWrites = (data.studyMaterials || []).map(mat => ({
    ref: db.collection('materials').doc(mat.materialId),
    data: convertDates(cleanForFirestore(mat)),
  }));
  await batchWrite(db, matWrites);
  log('✅', `${matWrites.length} materials seeded`, 'green');

  logSection('16. Syllabus Tracker');
  const sylWrites = (data.syllabusTracker || []).map(syl => ({
    ref: db.collection('syllabusTracker').doc(syl.trackerId),
    data: convertDates(cleanForFirestore(syl)),
  }));
  await batchWrite(db, sylWrites);
  log('✅', `${sylWrites.length} syllabus trackers seeded`, 'green');
}

// ─── WIPE ─────────────────────────────────────────────────────────────────────

async function wipeCollection(db, collectionName) {
  log('🗑️ ', `Wiping ${collectionName}...`, 'yellow');
  const snapshot = await db.collection(collectionName).get();
  if (snapshot.empty) return;

  const batch = db.batch();
  let count = 0;
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;
    if (count >= 490) break; // safety
  }
  await batch.commit();
  log('🗑️ ', `  Deleted ${count} docs from ${collectionName}`, 'yellow');
}

async function wipeAll(db) {
  logSection('WIPING ALL SEEDED COLLECTIONS');
  const collections = [
    'schools', 'users', 'students', 'teachers', 'classes',
    'subjects', 'timetable', 'homework', 'assignments', 'submissions',
    'tests', 'fees', 'leaves', 'announcements', 'materials', 'syllabusTracker',
  ];
  for (const col of collections) {
    await wipeCollection(db, col);
  }
  log('✅', 'Wipe complete', 'green');
}

// ─── VERIFY ───────────────────────────────────────────────────────────────────

async function verifyAll(db) {
  logSection('FIRESTORE VERIFICATION — DOCUMENT COUNTS');

  const collections = [
    'schools', 'users', 'students', 'teachers', 'classes',
    'subjects', 'timetable', 'homework', 'assignments', 'submissions',
    'tests', 'fees', 'leaves', 'announcements', 'materials', 'syllabusTracker',
  ];

  let allGood = true;

  for (const col of collections) {
    const snap = await db.collection(col).get();
    const count = snap.size;
    const ok = count > 0;
    if (!ok) allGood = false;

    const icon = ok ? '✅' : '❌';
    const color = ok ? 'green' : 'red';
    log(icon, `${col.padEnd(20)} ${count} docs`, color);
  }

  // Spot check: read back STU001
  console.log('');
  log('🔍', 'Spot check — reading STU001 from Firestore...', 'cyan');
  const stuSnap = await db.collection('students').doc('STU001').get();
  if (stuSnap.exists) {
    const d = stuSnap.data();
    log('✅', `STU001: ${d.personal?.fullName}, Class ${d.academic?.className}-${d.academic?.section}`, 'green');
  } else {
    log('❌', 'STU001 not found in Firestore', 'red');
    allGood = false;
  }

  // Spot check: read TCH001
  const tchSnap = await db.collection('teachers').doc('TCH001').get();
  if (tchSnap.exists) {
    const d = tchSnap.data();
    log('✅', `TCH001: ${d.personal?.fullName}, ${d.professional?.designation}`, 'green');
  } else {
    log('❌', 'TCH001 not found in Firestore', 'red');
    allGood = false;
  }

  // Spot check: attendance
  const attSnap = await db
    .collection('attendance')
    .doc('SCH001')
    .collection('2024-11-20')
    .doc('CLS_10A')
    .collection('students')
    .doc('STU001')
    .get();

  if (attSnap.exists) {
    log('✅', `Attendance STU001 on 2024-11-20: status = ${attSnap.data().status}`, 'green');
  } else {
    log('❌', 'Attendance STU001 on 2024-11-20 not found', 'red');
    allGood = false;
  }

  console.log('');
  if (allGood) {
    log('🎉', 'ALL CHECKS PASSED — Firestore is seeded correctly!', 'green');
  } else {
    log('⚠️ ', 'SOME CHECKS FAILED — re-run: node seed.js', 'red');
  }
}

// ─── COLLECTION ROUTER ────────────────────────────────────────────────────────

async function seedByName(db, name) {
  switch (name) {
    case 'school': return seedSchool(db);
    case 'classes': return seedClasses(db);
    case 'subjects': return seedSubjects(db);
    case 'students': return seedStudentsAndUsers(db);
    case 'teachers': return seedTeachersAndUsers(db);
    case 'timetable': return seedTimetable(db);
    case 'attendance': return seedAttendance(db);
    case 'academics': return seedAcademics(db);
    case 'fees':
    case 'leaves':
    case 'announcements':
    case 'notifications': return seedFeesLeavesAnnouncements(db);
    case 'materials': return seedMaterials(db);
    default:
      console.error(chalk.red(`Unknown collection: ${name}`));
      console.log(chalk.white('Valid options: school, classes, subjects, students, teachers, timetable, attendance, academics, fees, materials'));
      process.exit(1);
  }
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log(chalk.bold.blue('\n🚀 INDIVIO EDTECH — FIRESTORE SEED SCRIPT'));
  console.log(chalk.blue('=========================================='));

  if (isDryRun) console.log(chalk.yellow('  MODE: DRY RUN (no writes)'));
  if (isWipe) console.log(chalk.yellow('  MODE: WIPE + RESEED'));
  if (isVerify) console.log(chalk.cyan('  MODE: VERIFY ONLY'));
  if (targetCollection) console.log(chalk.cyan(`  MODE: SINGLE COLLECTION → ${targetCollection}`));

  console.log('');

  // Validate mock_db folder
  if (!fs.existsSync(CONFIG.mockDbPath)) {
    console.error(chalk.red(`❌ mock_db folder not found at: ${CONFIG.mockDbPath}`));
    console.error(chalk.yellow('   Copy your JSON files to a folder called mock_db/ next to seed.js'));
    process.exit(1);
  }

  const db = initFirebase();
  log('🔥', 'Firebase connected', 'green');

  // Verify-only mode
  if (isVerify) {
    await verifyAll(db);
    return;
  }

  // Wipe if requested
  if (isWipe && !isDryRun) {
    await wipeAll(db);
  }

  const startTime = Date.now();

  // Single collection mode
  if (targetCollection) {
    await seedByName(db, targetCollection);
  } else {
    // Full seed — in dependency order
    await seedSchool(db);
    await seedClasses(db);
    await seedSubjects(db);
    await seedStudentsAndUsers(db);
    await seedTeachersAndUsers(db);
    await seedTimetable(db);
    await seedAttendance(db);
    await seedAcademics(db);
    await seedFeesLeavesAnnouncements(db);
    await seedMaterials(db);
  }

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);

  console.log(chalk.bold.green('\n=========================================='));
  console.log(chalk.bold.green('  ✅ SEED COMPLETE'));
  console.log(chalk.green(`  📝 Documents written: ${totalWritten}`));
  console.log(chalk.green(`  ⏱️  Time: ${elapsed}s`));
  if (isDryRun) console.log(chalk.yellow('  (Dry run — nothing was actually written)'));
  console.log(chalk.bold.green('==========================================\n'));

  // Auto-verify after full seed
  if (!isDryRun && !targetCollection) {
    console.log(chalk.cyan('\nRunning automatic verification...\n'));
    await verifyAll(db);
  }
}

main().catch(err => {
  console.error(chalk.red('\n❌ SEED FAILED:'), err.message);
  console.error(err.stack);
  process.exit(1);
});