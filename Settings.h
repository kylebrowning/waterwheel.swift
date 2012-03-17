#define kDiosBaseUrl @"http://d7.workhabit.com"
#define kDiosEndpoint @"api"
#define kDiosBaseNode @"node"
#define kDiosBaseComment @"comment"
#define kDiosBaseUser @"user"
#define kDiosBaseFile @"file"
#define kDiosBaseView @"views"
#define kDiosBaseTaxonmyTerm @"taxonomy_term"
#define kDiosBaseTaxonmyVocabulary @"taxonomy_vocabulary"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif