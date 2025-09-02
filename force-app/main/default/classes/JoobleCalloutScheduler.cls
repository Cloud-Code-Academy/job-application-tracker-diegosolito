global class JoobleCalloutScheduler implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        JoobleApiCallout.callJoobleApi();
    }
}