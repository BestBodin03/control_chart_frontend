class CountExtractor {
 static int extractCountFromResponse(dynamic response) {
   try {
     final data = response.data;
     if (data is Map && data['count'] != null) {
       final count = data['count'] as int;
       return count;
     }
     return 0;
   } catch (e) {
     return 0;
   }
 }
}