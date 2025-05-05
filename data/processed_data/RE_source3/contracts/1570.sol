contract ReentryProtectorMixin {

    // true if we are inside an external function
    bool reentryProtector;

    // Mark 