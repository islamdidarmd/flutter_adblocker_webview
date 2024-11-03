#include "adblocker_core.h"
#include "third-party/ad-block/ad_block_client.h"
#include <string>
#include <vector>
#include <cstring>

class AdBlockerCoreImpl {
private:
    AdBlockClient* client;
    char* rawData;
    char* processedData;

public:
    AdBlockerCoreImpl() {
        client = new AdBlockClient();
        rawData = nullptr;
        processedData = nullptr;
    }

    ~AdBlockerCoreImpl() {
        delete client;
        delete[] rawData;
        delete[] processedData;
    }

    AdBlockClient* getClient() { return client; }
    const AdBlockClient* getClient() const { return client; }
};

// Constructor and destructor
extern "C" AdBlockerCore* adblocker_core_create() {
    return reinterpret_cast<AdBlockerCore*>(new AdBlockerCoreImpl());
}

extern "C" void adblocker_core_destroy(AdBlockerCore* core) {
    delete reinterpret_cast<AdBlockerCoreImpl*>(core);
}

// Core functionality
extern "C" bool adblocker_core_is_generic_element_hiding_enabled(const AdBlockerCore* core) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    return impl->getClient()->isGenericElementHidingEnabled;
}

extern "C" void adblocker_core_set_generic_element_hiding_enabled(AdBlockerCore* core, bool enabled) {
    auto impl = reinterpret_cast<AdBlockerCoreImpl*>(core);
    impl->getClient()->isGenericElementHidingEnabled = enabled;
}

extern "C" void adblocker_core_load_basic_data(AdBlockerCore* core, const char* data, size_t length, bool preserve_rules) {
    auto impl = reinterpret_cast<AdBlockerCoreImpl*>(core);
    impl->getClient()->parse(data, preserve_rules);
}

extern "C" void adblocker_core_load_processed_data(AdBlockerCore* core, const char* data, size_t length) {
    auto impl = reinterpret_cast<AdBlockerCoreImpl*>(core);
    impl->getClient()->deserialize(const_cast<char*>(data));
}

extern "C" ProcessedData adblocker_core_get_processed_data(const AdBlockerCore* core) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    int size;
    char* data = impl->getClient()->serialize(&size, false);
    return ProcessedData{data, static_cast<size_t>(size)};
}

extern "C" void processed_data_free(ProcessedData* data) {
    delete[] data->data;
    data->data = nullptr;
    data->length = 0;
}

extern "C" int32_t adblocker_core_get_filters_count(const AdBlockerCore* core) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    auto client = impl->getClient();
    return client->numFilters
           + client->numCosmeticFilters
           + client->numHtmlFilters
           + client->numScriptletFilters
           + client->numExceptionFilters
           + client->numNoFingerprintFilters
           + client->numNoFingerprintExceptionFilters
           + client->numNoFingerprintDomainOnlyFilters
           + client->numNoFingerprintAntiDomainOnlyFilters
           + client->numNoFingerprintDomainOnlyExceptionFilters
           + client->numNoFingerprintAntiDomainOnlyExceptionFilters
           + client->numHostAnchoredFilters
           + client->numHostAnchoredExceptionFilters;
}

extern "C" MatchResult adblocker_core_matches(const AdBlockerCore* core, const char* url, 
    const char* first_party_domain, int32_t filter_option) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    Filter* matchedFilter;
    Filter* matchedExceptionFilter;
    bool shouldBlock = const_cast<AdBlockerCoreImpl*>(impl)->getClient()->matches(
        url,
        static_cast<FilterOption>(filter_option),
        first_party_domain,
        &matchedFilter,
        &matchedExceptionFilter
    );

    return MatchResult{
        shouldBlock,
        matchedFilter ? matchedFilter->ruleDefinition : nullptr,
        matchedExceptionFilter ? matchedExceptionFilter->ruleDefinition : nullptr
    };
}

extern "C" const char* adblocker_core_get_element_hiding_selectors(const AdBlockerCore* core, const char* url) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    return const_cast<AdBlockClient*>(impl->getClient())->getElementHidingSelectors(url);
}

extern "C" StringArray adblocker_core_get_extended_css_selectors(const AdBlockerCore* core, const char* url) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    const LinkedList<std::string>* rules = const_cast<AdBlockClient*>(impl->getClient())->getExtendedCssSelectors(url);
    
    StringArray result = {nullptr, 0};
    if (rules && rules->length() > 0) {
        result.length = rules->length();
        result.data = new char*[result.length];
        size_t i = 0;
        for (const auto& rule : *rules) {
            result.data[i] = strdup(rule.c_str());
            i++;
        }
    }
    return result;
}

extern "C" StringArray adblocker_core_get_css_rules(const AdBlockerCore* core, const char* url) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    const LinkedList<std::string>* rules = const_cast<AdBlockClient*>(impl->getClient())->getCssRules(url);
    
    StringArray result = {nullptr, 0};
    if (rules && rules->length() > 0) {
        result.length = rules->length();
        result.data = new char*[result.length];
        size_t i = 0;
        for (const auto& rule : *rules) {
            result.data[i] = strdup(rule.c_str());
            i++;
        }
    }
    return result;
}

extern "C" StringArray adblocker_core_get_scriptlets(const AdBlockerCore* core, const char* url) {
    auto impl = reinterpret_cast<const AdBlockerCoreImpl*>(core);
    const LinkedList<std::string>* rules = const_cast<AdBlockClient*>(impl->getClient())->getScriptlets(url);
    
    StringArray result = {nullptr, 0};
    if (rules && rules->length() > 0) {
        result.length = rules->length();
        result.data = new char*[result.length];
        size_t i = 0;
        for (const auto& rule : *rules) {
            result.data[i] = strdup(rule.c_str());
            i++;
        }
    }
    return result;
}

extern "C" void string_array_free(StringArray* array) {
    if (array && array->data) {
        for (size_t i = 0; i < array->length; i++) {
            free(array->data[i]);
        }
        delete[] array->data;
        array->data = nullptr;
        array->length = 0;
    }
}

