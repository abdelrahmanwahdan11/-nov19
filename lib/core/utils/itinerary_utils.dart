import '../localization/app_localizations.dart';
import 'dummy_data.dart';

String localizedItineraryTag(String tag, AppLocalizations localization) {
  switch (tag) {
    case ItineraryTags.logistics:
      return localization.t('tagLogistics');
    case ItineraryTags.experience:
      return localization.t('tagExperience');
    case ItineraryTags.culinary:
      return localization.t('tagCulinary');
    case ItineraryTags.wellness:
      return localization.t('tagWellness');
    case ItineraryTags.tech:
      return localization.t('tagTech');
    default:
      return tag;
  }
}
