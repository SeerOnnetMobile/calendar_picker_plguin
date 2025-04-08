import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
class CalendarTool {
  /*  支持转换的最小农历年份 */
  static const int _MIN_YEAR = 1900;

  /*  支持转换的最大农历年份 */
  static const int _MAX_YEAR = 2099;

  /* 公历每月前的天数 */
  static const List<int> DAYS_BEFORE_MONTH = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

  /*
   * 用来表示1900年到2099年间农历年份的相关信息，共24位bit的16进制表示，其中：
   * 1. 前4位表示该年闰哪个月；
   * 2. 5-17位表示农历年份13个月的大小月分布，0表示小，1表示大；
   * 3. 最后7位表示农历年首（正月初一）对应的公历日期。
   * 以2014年的数据0x955ABF为例说明：
   * 1001 0101 0101 1010 1011 1111
   *  闰九月   农历正月初一对应公历1月31号
   */
  static const List<int> LUNAR_INFO = [
    /*1900*/
    0x84B6BF,
    /*1901-1910*/
    0x04AE53,
    0x0A5748,
    0x5526BD,
    0x0D2650,
    0x0D9544,
    0x46AAB9,
    0x056A4D,
    0x09AD42,
    0x24AEB6,
    0x04AE4A,
    /*1911-1920*/
    0x6A4DBE,
    0x0A4D52,
    0x0D2546,
    0x5D52BA,
    0x0B544E,
    0x0D6A43,
    0x296D37,
    0x095B4B,
    0x749BC1,
    0x049754,
    /*1921-1930*/
    0x0A4B48,
    0x5B25BC,
    0x06A550,
    0x06D445,
    0x4ADAB8,
    0x02B64D,
    0x095742,
    0x2497B7,
    0x04974A,
    0x664B3E,
    /*1931-1940*/
    0x0D4A51,
    0x0EA546,
    0x56D4BA,
    0x05AD4E,
    0x02B644,
    0x393738,
    0x092E4B,
    0x7C96BF,
    0x0C9553,
    0x0D4A48,
    /*1941-1950*/
    0x6DA53B,
    0x0B554F,
    0x056A45,
    0x4AADB9,
    0x025D4D,
    0x092D42,
    0x2C95B6,
    0x0A954A,
    0x7B4ABD,
    0x06CA51,
    /*1951-1960*/
    0x0B5546,
    0x555ABB,
    0x04DA4E,
    0x0A5B43,
    0x352BB8,
    0x052B4C,
    0x8A953F,
    0x0E9552,
    0x06AA48,
    0x6AD53C,
    /*1961-1970*/
    0x0AB54F,
    0x04B645,
    0x4A5739,
    0x0A574D,
    0x052642,
    0x3E9335,
    0x0D9549,
    0x75AABE,
    0x056A51,
    0x096D46,
    /*1971-1980*/
    0x54AEBB,
    0x04AD4F,
    0x0A4D43,
    0x4D26B7,
    0x0D254B,
    0x8D52BF,
    0x0B5452,
    0x0B6A47,
    0x696D3C,
    0x095B50,
    /*1981-1990*/
    0x049B45,
    0x4A4BB9,
    0x0A4B4D,
    0xAB25C2,
    0x06A554,
    0x06D449,
    0x6ADA3D,
    0x0AB651,
    0x095746,
    0x5497BB,
    /*1991-2000*/
    0x04974F,
    0x064B44,
    0x36A537,
    0x0EA54A,
    0x86B2BF,
    0x05AC53,
    0x0AB647,
    0x5936BC,
    0x092E50,
    0x0C9645,
    /*2001-2010*/
    0x4D4AB8,
    0x0D4A4C,
    0x0DA541,
    0x25AAB6,
    0x056A49,
    0x7AADBD,
    0x025D52,
    0x092D47,
    0x5C95BA,
    0x0A954E,
    /*2011-2020*/
    0x0B4A43,
    0x4B5537,
    0x0AD54A,
    0x955ABF,
    0x04BA53,
    0x0A5B48,
    0x652BBC,
    0x052B50,
    0x0A9345,
    0x474AB9,
    /*2021-2030*/
    0x06AA4C,
    0x0AD541,
    0x24DAB6,
    0x04B64A,
    0x6a573D,
    0x0A4E51,
    0x0D2646,
    0x5E933A,
    0x0D534D,
    0x05AA43,
    /*2031-2040*/
    0x36B537,
    0x096D4B,
    0xB4AEBF,
    0x04AD53,
    0x0A4D48,
    0x6D25BC,
    0x0D254F,
    0x0D5244,
    0x5DAA38,
    0x0B5A4C,
    /*2041-2050*/
    0x056D41,
    0x24ADB6,
    0x049B4A,
    0x7A4BBE,
    0x0A4B51,
    0x0AA546,
    0x5B52BA,
    0x06D24E,
    0x0ADA42,
    0x355B37,
    /*2051-2060*/
    0x09374B,
    0x8497C1,
    0x049753,
    0x064B48,
    0x66A53C,
    0x0EA54F,
    0x06AA44,
    0x4AB638,
    0x0AAE4C,
    0x092E42,
    /*2061-2070*/
    0x3C9735,
    0x0C9649,
    0x7D4ABD,
    0x0D4A51,
    0x0DA545,
    0x55AABA,
    0x056A4E,
    0x0A6D43,
    0x452EB7,
    0x052D4B,
    /*2071-2080*/
    0x8A95BF,
    0x0A9553,
    0x0B4A47,
    0x6B553B,
    0x0AD54F,
    0x055A45,
    0x4A5D38,
    0x0A5B4C,
    0x052B42,
    0x3A93B6,
    /*2081-2090*/
    0x069349,
    0x7729BD,
    0x06AA51,
    0x0AD546,
    0x54DABA,
    0x04B64E,
    0x0A5743,
    0x452738,
    0x0D264A,
    0x8E933E,
    /*2091-2099*/
    0x0D5252,
    0x0DAA47,
    0x66B53B,
    0x056D4F,
    0x04AE45,
    0x4A4EB9,
    0x0A4D4C,
    0x0D1541,
    0x2D92B5
  ];

  // 计算阳历的这个年份这个月份，天数有几天
  static getYangliDay(year, month) {
    int count = 0;

    //判断大月份

    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
      count = 31;
    }

    //判断小月

    if (month == 4 || month == 6 || month == 9 || month == 11) {
      count = 30;
    }

    //判断平年与闰年

    if (month == 2) {
      if (isLeapYear(year)) {
        count = 29;
      } else {
        count = 28;
      }
    }

    return count;
  }

  // 是否是闰年
  static bool isLeapYear(int year) {
    return ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
  }

  /*
   * 将农历日期转换为公历日期
   * @param year    农历年份
   * @param month   农历月
   * @param monthDay   农历日
   * @param isLeapMonth   该月是否是闰月(该参数可以根据本类中leapMonth()方法，先判断一下要查询的年份是否有闰月，并且闰的几月)
   * @return 返回农历日期对应的公历日期，year0, month1, day2.
   */
  static List<int> lunarToSolar(int year, int month, int monthDay, bool isLeapMonth) {
    int leapMonth;
    int dayOffset;
    int i;
    if (year < _MIN_YEAR || year > _MAX_YEAR || month < 1 || month > 12 || monthDay < 1 || monthDay > 30) {
      throw Exception("入参不合规则:\n\tyear 范围: 1900~2099\n\tmonth 范围: 1~12\n\tday 范围: 1~30");
    }
    dayOffset = (LUNAR_INFO[year - _MIN_YEAR] & 0x001F) - 1;
    if (((LUNAR_INFO[year - _MIN_YEAR] & 0x0060) >> 5) == 2) {
      dayOffset += 31;
    }
    for (i = 1; i < month; i++) {
      if ((LUNAR_INFO[year - _MIN_YEAR] & (0x80000 >> (i - 1))) == 0) {
        dayOffset += 29;
      } else {
        dayOffset += 30;
      }
    }
    dayOffset += monthDay;
    leapMonth = (LUNAR_INFO[year - _MIN_YEAR] & 0xf00000) >> 20;
    // 这一年有闰月
    if (leapMonth != 0) {
      if (month > leapMonth || (month == leapMonth && isLeapMonth)) {
        if ((LUNAR_INFO[year - _MIN_YEAR] & (0x80000 >> (month - 1))) == 0) {
          dayOffset += 29;
        } else {
          dayOffset += 30;
        }
      }
    }
    if (dayOffset > 366 || (year % 4 != 0 && dayOffset > 365)) {
      year += 1;
      if (year % 4 == 1) {
        dayOffset -= 366;
      } else {
        dayOffset -= 365;
      }
    }
    List<int> solarInfo = [0, 0, 0];
    for (i = 1; i < 13; i++) {
      int iPos = DAYS_BEFORE_MONTH[i];
      if (year % 4 == 0 && i > 2) {
        iPos += 1;
      }
      if (year % 4 == 0 && i == 2 && iPos + 1 == dayOffset) {
        solarInfo[1] = i;
        solarInfo[2] = dayOffset - 31;
        break;
      }
      if (iPos >= dayOffset) {
        solarInfo[1] = i;
        iPos = DAYS_BEFORE_MONTH[i - 1];
        if (year % 4 == 0 && i > 2) {
          iPos += 1;
        }
        if (dayOffset > iPos) {
          solarInfo[2] = dayOffset - iPos;
        } else if (dayOffset == iPos) {
          if (year % 4 == 0 && i == 2) {
            solarInfo[2] = DAYS_BEFORE_MONTH[i] - DAYS_BEFORE_MONTH[i - 1] + 1;
          } else {
            solarInfo[2] = DAYS_BEFORE_MONTH[i] - DAYS_BEFORE_MONTH[i - 1];
          }
        } else {
          solarInfo[2] = dayOffset;
        }
        break;
      }
    }
    solarInfo[0] = year;
    return solarInfo;
  }

  /*
   * 传回农历year年month月的总天数
   *
   * @param year   要计算的年份
   * @param month        要计算的月
   * @return 传回天数
   */
  static int daysInMonth(int year, int month) {
    return daysInMontaThree(year, month, false);
  }

  /*
   * 传回农历year年month月的总天数
   *
   * @param year   要计算的年份
   * @param month    要计算的月
   * @param leap   当月是否是闰月
   * @return 传回天数，如果闰月是错误的，返回0.
   */
  static int daysInMontaThree(int year, int month, bool leap) {
    int mLeapMonth = leapMonth(year);
    int offset = 0;
    // 如果本年有闰月且month大于闰月时，需要校正
    if (leapMonth != 0 && month > mLeapMonth) {
      offset = 1;
    }
    // 不考虑闰月
    if (!leap) {
      return daysInLunarMonth(year, month + offset);
    } else {
      // 传入的闰月是正确的月份
      if (leapMonth != 0 && leapMonth == month) {
        return daysInLunarMonth(year, month + 1);
      }
    }
    return 0;
  }

  /*
   * 传回农历 year年的总天数
   *
   * @param year 将要计算的年份
   * @return 返回传入年份的总天数
   */
  static int daysInLunarYear(int year) {
    int i, sum = 348;
    if (leapMonth(year) != 0) {
      sum = 377;
    }
    int monthInfo = LUNAR_INFO[year - _MIN_YEAR] & 0x0FFF80;
    for (i = 0x80000; i > 0x7; i >>= 1) {
      if ((monthInfo & i) != 0) {
        sum += 1;
      }
    }
    return sum;
  }

  /*
   * 传回农历 year年month月的总天数，总共有13个月包括闰月
   *
   * @param year  将要计算的年份
   * @param month 将要计算的月份
   * @return 传回农历 year年month月的总天数
   */
  static int daysInLunarMonth(int year, int month) {
    if ((LUNAR_INFO[year - _MIN_YEAR] & (0x100000 >> month)) == 0) {
      return 29;
    } else {
      return 30;
    }
  }

  /*
   * 传回农历 year年闰哪个月 1-12 , 没闰传回 0
   * @param year 将要计算的年份
   * @return 传回农历 year年闰哪个月1-12, 没闰传回 0
   */
  static int leapMonth(int year) {
    return ((LUNAR_INFO[year - _MIN_YEAR] & 0xF00000)) >> 20;
  }

  /*
   * 传回日期信息
   */
  static List<int> solarDateToIntList(int timestamp, {String? utcZone}) {
    if (utcZone != null) {
      tz_data.initializeTimeZones();
      final date = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.getLocation(utcZone!), timestamp * 1000);
      return [date.year, date.month, date.day, date.hour, date.minute];
    } else {
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return [date.year, date.month, date.day, date.hour, date.minute];
    }
  }

  static List<int> solarDateToLunar(int timestamp, {String? utcZone}) {
    //参数区间1900.1.31~2100.12.31
    // var y = int.parse(yearsolar2lunar);
    // var m = int.parse(monthsolar2lunar);
    // var d = int.parse(daysolar2lunar);
    //年份限定、上限

    DateTime cal = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    if (utcZone != null) {
      tz_data.initializeTimeZones();
      cal = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.getLocation(utcZone!), timestamp * 1000);
    }
    var y = cal.year;
    var m = cal.month;
    var d = cal.day;

    // var result = lunarx(y, m, d);
    if (y < 1900 || y > 2100) {
      return [];
    }
    //公历传参最下限
    if (y == 1900 && m == 1 && d < 31) {
      return [];
    }
    //未传参  获得当天
    var objDate;
    if (y == 0) {
      objDate = DateTime.now();
    } else {
      objDate = DateTime(y, m, d);
    }
    var i;
    int temp = 0;
    //修正ymd参数
    y = objDate.year;
    m = objDate.month;
    d = objDate.day;

    final date1 = DateTime(y, m, d, 0, 0, 0);
    final date2 = DateTime(1900, 1, 31, 0, 0, 0);
    final timeStamp2 = date2.millisecondsSinceEpoch;
    final diffMilliseconds = date1.millisecondsSinceEpoch - timeStamp2;
    var offset = (diffMilliseconds / 86400000).round();

    for (i = 1900; i < 2101 && offset > 0; i++) {
      temp = daysInLunarYear(i);
      offset -= temp;
    }
    if (offset < 0) {
      offset += temp;
      i--;
    }

    //数字表示周几顺应天朝周一开始的惯例
    // if (nWeek == 0) {
    //   nWeek = 7;
    // }
    //农历年
    var year = i;
    var _leap = leapMonth(i); //闰哪个月
    var isLeap = false;
    var isAfterLeap = false;

    //效验闰月
    for (i = 1; i < 13 && offset > 0; i++) {
      //闰月
      if (_leap > 0 && i == _leap + 1 && isLeap == false) {
        --i;
        isLeap = true;
        isAfterLeap = true;
        temp = daysInLunarMonth(year, _leap + 1); //计算农历闰月天数
      } else if (isAfterLeap == true) {
        temp = daysInLunarMonth(year, i + 1);
      } else {
        temp = daysInLunarMonth(year, i); //计算农历普通月天数
      }
      //解除闰月
      if (isLeap == true && i == _leap + 1) {
        isLeap = false;
      }
      offset -= temp;
    }
    // 闰月导致数组下标重叠取反
    if (offset == 0 && _leap > 0 && i == _leap + 1) {
      if (isLeap) {
        isLeap = false;
      } else {
        isLeap = true;
        --i;
      }
    }
    if (offset < 0) {
      offset += temp;
      --i;
    }
    //农历月
    var month = i;
    //农历日
    var day = offset + 1;

    return [year, month, day, cal.hour,cal.minute, isLeap ? 1 : 0];
  }

  static bool isTimeZoneValid(String timeZoneId) {
    try {
      tz_data.initializeTimeZones();
      tz.getLocation(timeZoneId); // 尝试获取时区
      return true; // 未抛出异常，说明合法
    } catch (e) {
      return false; // 捕获异常，说明不合法
    }
  }
}
