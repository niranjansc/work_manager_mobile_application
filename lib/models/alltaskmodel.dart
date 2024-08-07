// ignore_for_file: public_member_api_docs, sort_constructors_first
class AllTaskModel {
  late String taskid;
  late String phaseid;
  late String PersonName;
  late String InstName;
  late String country;
  late String state;
  late String district;
  late String taluk;
  late String city;
  late String FrmDt;
  late String desc;
  late String phase;

  late String todt;
  AllTaskModel({
    this.taskid = '',
    this.phaseid = '',
    required this.PersonName,
    required this.InstName,
    required this.FrmDt,
    required this.todt,
    this.desc = '',
    this.phase = '',
    this.country = '',
    this.state = '',
    this.district = '',
    this.taluk = '',
    this.city = '',
  });
}
