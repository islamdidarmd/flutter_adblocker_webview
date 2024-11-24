#ifndef EASYLIST_BRIDGE_H
#define EASYLIST_BRIDGE_H

#include <stdint.h>
#include "parser/easylist_parser.h"

#ifdef __cplusplus
extern "C" {
#endif

// Opaque type for EasyListParser
typedef struct EasyListParser EasyListParser;

#ifdef _WIN32
    #define EASYLIST_EXPORT __declspec(dllexport)
#else
    #define EASYLIST_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

// Parser creation and destruction
EASYLIST_EXPORT EasyListParser* easy_list_create_parser();
EASYLIST_EXPORT void easy_list_destroy_parser(EasyListParser* parser);

// Core functionality
EASYLIST_EXPORT bool easy_list_load_from_file(EasyListParser* parser, const char* file_path);
EASYLIST_EXPORT bool easy_list_is_url_blocked(EasyListParser* parser, const char* url);
EASYLIST_EXPORT char* easy_list_get_ad_selectors(EasyListParser* parser);
// Structure to return array of strings
typedef struct {
    char** data;
    size_t length;
} StringArray;
// Memory management
EASYLIST_EXPORT void easy_list_free_string(char* str);

EASYLIST_EXPORT StringArray easy_list_get_blocked_domains(EasyListParser* parser);
EASYLIST_EXPORT void easy_list_free_string_array(StringArray array);

#ifdef __cplusplus
}
#endif

#endif // EASYLIST_BRIDGE_H