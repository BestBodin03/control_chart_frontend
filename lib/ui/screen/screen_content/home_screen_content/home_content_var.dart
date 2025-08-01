

class HomeContentVar {       
  // static const sampleData = [
  //   ChartDataPoint(label: '330', value: 300),
  //   ChartDataPoint(label: '430', value: 500),
  //   ChartDataPoint(label: '530', value: 600),
  //   ChartDataPoint(label: '630', value: 700),
  // ];
  
  static getQueryParams(dynamic searchState) => searchState.currentQuery;
//   final uniqueKey = '${query?.startDate?.millisecondsSinceEpoch ?? 0}-'
//       '${query?.endDate?.millisecondsSinceEpoch ?? 0}-'
//       '${query?.furnaceNo ?? 'none'}-'
//       '${query?.materialNo ?? 'none'}';
// }
}