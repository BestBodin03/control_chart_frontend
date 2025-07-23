class CountExtractor {
 static int extractCountFromResponse(dynamic response) {
   try {
     final data = response.data;
     if (data is Map && data['count'] != null) {
       final count = data['count'] as int;
       print('Count: $count');
       return count;
     }
     
     print('No count found, returning 0');
     return 0;
   } catch (e) {
     print('Error: $e');
     return 0;
   }
 }
}