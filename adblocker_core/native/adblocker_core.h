#ifndef ADBLOCKER_CORE_H
#define ADBLOCKER_CORE_H

#include <stddef.h>  // For size_t
#include <stdint.h>  // For fixed-width integer types
#include <stdbool.h> // For bool type

#ifdef __cplusplus
extern "C" {
#endif

// Opaque pointer to hide C++ implementation
typedef struct AdBlockerCore AdBlockerCore;

// Result structure for matches - using C-compatible types
typedef struct {
    bool should_block;
    const char* matched_rule;         // Owned by AdBlockClient, do not free
    const char* matched_exception_rule; // Owned by AdBlockClient, do not free
} MatchResult;

// Constructor and destructor
AdBlockerCore* adblocker_core_create();
void adblocker_core_destroy(AdBlockerCore* core);

// Core functionality
bool adblocker_core_is_generic_element_hiding_enabled(const AdBlockerCore* core);
void adblocker_core_set_generic_element_hiding_enabled(AdBlockerCore* core, bool enabled);
void adblocker_core_load_basic_data(AdBlockerCore* core, const char* data, size_t length, bool preserve_rules);
void adblocker_core_load_processed_data(AdBlockerCore* core, const char* data, size_t length);

// For processed data output
typedef struct {
    char* data;
    size_t length;
} ProcessedData;

ProcessedData adblocker_core_get_processed_data(const AdBlockerCore* core);
void processed_data_free(ProcessedData* data);

int32_t adblocker_core_get_filters_count(const AdBlockerCore* core);

// Matching and filtering
MatchResult adblocker_core_matches(const AdBlockerCore* core, const char* url, const char* first_party_domain, int32_t filter_option);

const char* adblocker_core_get_element_hiding_selectors(const AdBlockerCore* core, const char* url);

// For string array outputs
typedef struct {
    char** data;
    size_t length;
} StringArray;

StringArray adblocker_core_get_extended_css_selectors(const AdBlockerCore* core, const char* url);
StringArray adblocker_core_get_css_rules(const AdBlockerCore* core, const char* url);
StringArray adblocker_core_get_scriptlets(const AdBlockerCore* core, const char* url);
void string_array_free(StringArray* array);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif // ADBLOCKER_CORE_H

