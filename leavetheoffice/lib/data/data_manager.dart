import 'package:leavetheoffice/data/attendance.dart';
import 'package:leavetheoffice/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'att_data_format.dart';
import 'staff_info_data.dart';

class DataManager {
  Future<Staff_info> getStaffInfo(int id) async {
    // 지정된 한 명의 정보를 가져옴
    Database db = await getDatabaseHelper().getDatabase();
    List<Map<String, dynamic>> row = await db.query(Staff_info.memTableName,
        where: "${Staff_info.columnId} = ?", whereArgs: [id]);
    return getDatabaseHelper().rowToMem(row.single);
  }

  Future<List<Staff_info>> staffList() async {
    // 저장된 모든 스탭의 정보를 가져옴
    Database db = await getDatabaseHelper().getDatabase();
    List<Map<String, dynamic>> rows = await db.query(Staff_info.memTableName);
    if (rows.isEmpty) {
      // 초기값(스타팅 멤버) 정보 삽입. 앱 설치 후 최초 1회 실행
      await initData();
      rows = await db.query(Staff_info.memTableName);
    }
    return rows.map((row) => getDatabaseHelper().rowToMem(row)).toList();
  }

  Future<void> addStaff(Staff_info newStaff) async {
    // 스탭 정보를 데이터베이스에 추가함
    Database db = await getDatabaseHelper().getDatabase();
    db.insert(Staff_info.memTableName, getDatabaseHelper().memToRow(newStaff));
  }

  Future<void> updateStaff(int id, Staff_info info) async {
    // 스탭 정보를 수정함
    Database db = await getDatabaseHelper().getDatabase();
    db.update(Staff_info.memTableName, getDatabaseHelper().memToRow(info),
        where: "${Staff_info.columnId} = ?", whereArgs: [id]);
  }

  Future<void> deleteStaff(int id) async {
    // 스텝 정보를 삭제함
    Database db = await getDatabaseHelper().getDatabase();
    db.delete(Staff_info.memTableName,
        where: "${Staff_info.columnId} = ?", whereArgs: [id]);
  }

  Future<void> addAttData(Attendance att) async {
    // 근태 기록을 추가함(출근하기 버튼 클릭 시 실행)
    Database db = await getDatabaseHelper().getDatabase();
    db.insert(Attendance.attTableName, getDatabaseHelper().attToRow(att));
  }

  Future<void> updateAttData(Attendance att, int id, Date date) async {
    // 근태 기록을 수정함(퇴근하기 버튼 클릭 시 실행)
    Database db = await getDatabaseHelper().getDatabase();
    db.update(Attendance.attTableName, getDatabaseHelper().attToRow(att),
        where: "${Attendance.columnId} = ? and ${Attendance.columnDate} = ?",
        whereArgs: [id, date.toString()]);
  }

  Future<Attendance> getAtt(int id, Date date) async {
    // 지정된 개인의 지정된 날짜 근태 기록을 가져옴
    Database db = await getDatabaseHelper().getDatabase();
    List<Map<String, dynamic>> row = await db.query(Attendance.attTableName,
        where: "${Attendance.columnId} = ? and ${Attendance.columnDate} = ?",
        whereArgs: [id, date.toString()]);
    return getDatabaseHelper().rowToAtt(row.single);
  }

  Future<List<Attendance>> getTodayAtts(Date date) async {
    // 오늘의 모든 근태 기록을 가져옴
    Database db = await getDatabaseHelper().getDatabase();
    List<Map<String, dynamic>> rows = await db.query(Attendance.attTableName,
        where: "${Attendance.columnDate} = ?", whereArgs: [date.toString()]);
    return rows.map((row) => getDatabaseHelper().rowToAtt(row)).toList();
  }

  Future<List<Staff_info>> getStaffInfoListWithAttendance(Date date) async {
    Database db = await getDatabaseHelper().getDatabase();
    String sql = '''
    SELECT * FROM ${Staff_info.memTableName} 
    LEFT OUTER JOIN 
    (SELECT * FROM ${Attendance.attTableName} WHERE ${Attendance.columnDate} = '${date.toString()}') AS todayTable 
    ON ${Staff_info.memTableName}.${Staff_info.columnId} = todayTable.${Attendance.columnId};
    ''';
    List<Map<String, dynamic>> rows = await db.rawQuery(sql);
    return rows.map((e) => getDatabaseHelper().rowToStaffInfoWithAtt(e)).toList();
  }

  Future<void> initData() async {
    // 앱 최초 설치/실행 시 추가되는 데이터
    await addStaff(new Staff_info("이아영", "DESIGNER"));
    await addStaff(new Staff_info("김도연", "DEVELOPER"));
    await addStaff(new Staff_info("박지윤", "DEVELOPER"));
    await addStaff(new Staff_info("박정아", "PM"));
    await addStaff(new Staff_info("상한규", "INTERN"));
    await addStaff(new Staff_info("당병진", "DEVELOPER"));
  }
}
