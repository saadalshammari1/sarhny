import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'صارحني'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'تعبير أصيل عن الذات'**
  String get tagline;

  /// No description provided for @splashLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك'**
  String get loginTitle;

  /// No description provided for @loginEmailOrUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم أو البريد'**
  String get loginEmailOrUsername;

  /// No description provided for @loginPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In ar, this message translates to:
  /// **'سجّل'**
  String get loginSignUp;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك'**
  String get registerTitle;

  /// No description provided for @registerName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get registerName;

  /// No description provided for @registerUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get registerUsername;

  /// No description provided for @registerEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get registerPassword;

  /// No description provided for @registerButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get registerButton;

  /// No description provided for @registerHasAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get registerHasAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In ar, this message translates to:
  /// **'ادخل'**
  String get registerSignIn;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navInbox.
  ///
  /// In ar, this message translates to:
  /// **'الوارد'**
  String get navInbox;

  /// No description provided for @navCompose.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get navCompose;

  /// No description provided for @navMirrors.
  ///
  /// In ar, this message translates to:
  /// **'المرايا'**
  String get navMirrors;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @feedGlobalTab.
  ///
  /// In ar, this message translates to:
  /// **'العالمي'**
  String get feedGlobalTab;

  /// No description provided for @feedFollowingTab.
  ///
  /// In ar, this message translates to:
  /// **'أتابعهم'**
  String get feedFollowingTab;

  /// No description provided for @feedSectionAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get feedSectionAll;

  /// No description provided for @feedSectionMoment.
  ///
  /// In ar, this message translates to:
  /// **'لحظات'**
  String get feedSectionMoment;

  /// No description provided for @feedSectionFace.
  ///
  /// In ar, this message translates to:
  /// **'صور'**
  String get feedSectionFace;

  /// No description provided for @feedSectionMind.
  ///
  /// In ar, this message translates to:
  /// **'أفكار'**
  String get feedSectionMind;

  /// No description provided for @postCrystalBadge.
  ///
  /// In ar, this message translates to:
  /// **'متبلور'**
  String get postCrystalBadge;

  /// No description provided for @postLayersHint.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ'**
  String get postLayersHint;

  /// No description provided for @postGravityApproaching.
  ///
  /// In ar, this message translates to:
  /// **'يقترب من التبلور'**
  String get postGravityApproaching;

  /// No description provided for @postGravityFading.
  ///
  /// In ar, this message translates to:
  /// **'يتلاشى'**
  String get postGravityFading;

  /// No description provided for @composeChooseSection.
  ///
  /// In ar, this message translates to:
  /// **'اختر القسم'**
  String get composeChooseSection;

  /// No description provided for @composeMoment.
  ///
  /// In ar, this message translates to:
  /// **'لحظة'**
  String get composeMoment;

  /// No description provided for @composeFace.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get composeFace;

  /// No description provided for @composeMind.
  ///
  /// In ar, this message translates to:
  /// **'فكرة'**
  String get composeMind;

  /// No description provided for @composeLayer1.
  ///
  /// In ar, this message translates to:
  /// **'النص الأساسي'**
  String get composeLayer1;

  /// No description provided for @composeLayer2.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة (اختياري)'**
  String get composeLayer2;

  /// No description provided for @composeLayer3.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مقالاً عميقاً (اختياري)'**
  String get composeLayer3;

  /// No description provided for @composeCrystallizeHint.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ بعمر 24 ساعة — يتبلور إن تجاوب'**
  String get composeCrystallizeHint;

  /// No description provided for @composePublish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get composePublish;

  /// No description provided for @profileEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get profileEdit;

  /// No description provided for @profileFollow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get profileFollow;

  /// No description provided for @profileFollowing.
  ///
  /// In ar, this message translates to:
  /// **'أتابعه'**
  String get profileFollowing;

  /// No description provided for @profileBlock.
  ///
  /// In ar, this message translates to:
  /// **'حظر'**
  String get profileBlock;

  /// No description provided for @profileFollowers.
  ///
  /// In ar, this message translates to:
  /// **'متابعون'**
  String get profileFollowers;

  /// No description provided for @profileCrystals.
  ///
  /// In ar, this message translates to:
  /// **'متبلور'**
  String get profileCrystals;

  /// No description provided for @profileReplies.
  ///
  /// In ar, this message translates to:
  /// **'الردود'**
  String get profileReplies;

  /// No description provided for @profileTabCrystals.
  ///
  /// In ar, this message translates to:
  /// **'المتبلور'**
  String get profileTabCrystals;

  /// No description provided for @profileTabActive.
  ///
  /// In ar, this message translates to:
  /// **'النشط'**
  String get profileTabActive;

  /// No description provided for @profileTabMirrors.
  ///
  /// In ar, this message translates to:
  /// **'المرايا'**
  String get profileTabMirrors;

  /// No description provided for @profileTabLikes.
  ///
  /// In ar, this message translates to:
  /// **'الإعجابات'**
  String get profileTabLikes;

  /// No description provided for @inboxTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل المجهولة'**
  String get inboxTitle;

  /// No description provided for @inboxEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get inboxEmpty;

  /// No description provided for @inboxReplyPublic.
  ///
  /// In ar, this message translates to:
  /// **'رد علناً'**
  String get inboxReplyPublic;

  /// No description provided for @inboxIgnore.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get inboxIgnore;

  /// No description provided for @inboxReport.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ'**
  String get inboxReport;

  /// No description provided for @inboxDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get inboxDelete;

  /// No description provided for @mirrorsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرايا'**
  String get mirrorsTitle;

  /// No description provided for @mirrorsCreate.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ مرآة جديدة'**
  String get mirrorsCreate;

  /// No description provided for @mirrorsShare.
  ///
  /// In ar, this message translates to:
  /// **'شارك الرابط'**
  String get mirrorsShare;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settingsAccount;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get settingsPrivacy;

  /// No description provided for @settingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get settingsNotifications;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// No description provided for @settingsAnonymous.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل المجهولة'**
  String get settingsAnonymous;

  /// No description provided for @settingsSubscription.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك'**
  String get settingsSubscription;

  /// No description provided for @settingsHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get settingsHelp;

  /// No description provided for @settingsLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج'**
  String get settingsLogout;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get commonShare;

  /// No description provided for @commonReport.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ'**
  String get commonReport;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get commonError;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى'**
  String get commonEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
