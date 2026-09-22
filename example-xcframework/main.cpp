#include <boost/filesystem.hpp>
#include <boost/regex.hpp>
#include <boost/version.hpp>
#if BOOST_VERSION >= 106200
#include <boost/qvm/vec.hpp>
#endif
#if BOOST_VERSION >= 106300
#include <boost/atomic.hpp>
#include <boost/type_index/runtime_cast.hpp>
#endif
#if BOOST_VERSION >= 108500
#include <boost/charconv.hpp>
#endif
#if BOOST_VERSION >= 109200
#include <boost/container/hub.hpp>
#include <boost/decimal.hpp>
#include <boost/lockfree/bounded_ticket_queue.hpp>
#include <boost/system/unwrap_and_invoke.hpp>
#endif

#include <iostream>

#if BOOST_VERSION >= 106300
struct RuntimeBase {
    BOOST_TYPE_INDEX_REGISTER_RUNTIME_CLASS()
    virtual ~RuntimeBase() {}
};

struct RuntimeDerived : RuntimeBase {
#if BOOST_VERSION >= 108400
    BOOST_TYPE_INDEX_REGISTER_RUNTIME_CLASS(RuntimeBase)
#else
    BOOST_TYPE_INDEX_REGISTER_RUNTIME_CLASS((RuntimeBase))
#endif
};
#endif

int main()
{
    const boost::filesystem::path path("/tmp/ofxiOSBoost/example.txt");
    const boost::regex expected("example\\.txt");

    if (!boost::regex_match(path.filename().string(), expected)) {
        return 1;
    }

#if BOOST_VERSION >= 106200
    // QVM is new in Boost 1.62 and is supplied by the packaged header tree.
    const boost::qvm::vec<float, 3> vector = {{1.0f, 2.0f, 3.0f}};
    if (vector.a[0] + vector.a[1] + vector.a[2] != 6.0f) {
        return 2;
    }
#endif

#if BOOST_VERSION >= 106300
    // TypeIndex runtime_cast and Atomic::is_always_lock_free are new in 1.63.
    RuntimeDerived derived;
    RuntimeBase *base = &derived;
    if (boost::typeindex::runtime_cast<RuntimeDerived *>(base) != &derived) {
        return 3;
    }
    if (boost::atomic<int>::is_always_lock_free != boost::atomic<int>().is_lock_free()) {
        return 4;
    }
#endif

#if BOOST_VERSION >= 108500
    char buffer[32]{};
    const auto encoded = boost::charconv::to_chars(buffer, buffer + sizeof(buffer), 85.25);
    double decoded = 0.0;
    const auto parsed = boost::charconv::from_chars(buffer, encoded.ptr, decoded);
    if (encoded.ec != std::errc() || parsed.ec != std::errc() || decoded != 85.25) return 5;
#endif

#if BOOST_VERSION >= 109200
    boost::container::hub<int> values;
    for (int value = 0; value < 8; ++value) values.insert(value);
    boost::container::erase_if(values, [](int value) { return value % 2 != 0; });
    if (values.size() != 4) return 6;
    const auto decimal = boost::decimal::decompose(boost::decimal::decimal64_t{-12345, -2});
    if (!decimal.sign || decimal.sig != 12345U || decimal.exp != -2) return 7;
    boost::lockfree::bounded_ticket_queue<int, boost::lockfree::capacity<8>> queue;
    int queued = 0;
    if (!queue.push(19) || !queue.push(92) || !queue.pop(queued) || queued != 19 ||
        !queue.pop(queued) || queued != 92 || !queue.empty()) return 8;
    int observed = 0;
    boost::system::result<int> input(92);
    boost::system::result<void> result = boost::system::unwrap_and_invoke(
        [&observed](int value) { observed = value; }, input);
    if (!result.has_value() || observed != 92) return 9;
#endif

    std::cout << "Boost " << BOOST_LIB_VERSION << " XCFramework linked successfully\n";
    return 0;
}
