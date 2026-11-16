import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppStrings extends Translations {
  static const locales = [Locale('en'), Locale('ar')];

  static const _copy = <String, (String, String)>{
    'auth_storage_error': (
      'Could not access the local account. Try again.',
      'تعذّر الوصول إلى الحساب على الجهاز. حاول مرة أخرى.',
    ),
    'check_in_title': ('Health check-in', 'المتابعة الصحية'),
    'check_in_heading': ('Log your readings', 'سجّل قراءاتك'),
    'check_in_select': (
      'Choose diabetes, high blood pressure, or both.',
      'اختَر السكري أو الضغط أو الاثنين.',
    ),
    'check_in_diabetes': ('Diabetes', 'السكري'),
    'check_in_hypertension': ('High blood pressure', 'ارتفاع ضغط الدم'),
    'check_in_enter': (
      'Enter one or both readings from your meter.',
      'أدخل قراءة واحدة أو القراءتين من جهاز القياس.',
    ),
    'check_in_glucose': ('Blood sugar', 'سكر الدم'),
    'check_in_glucose_value': ('Glucose reading', 'قراءة السكر'),
    'check_in_pressure': ('Blood pressure', 'ضغط الدم'),
    'check_in_systolic': ('Systolic (top number)', 'الانقباضي (الرقم العلوي)'),
    'check_in_diastolic': (
      'Diastolic (bottom number)',
      'الانبساطي (الرقم السفلي)',
    ),
    'check_in_timing': ('When did you measure it?', 'إمتى قست السكر؟'),
    'check_in_before_meal': ('Before a meal', 'قبل الأكل'),
    'check_in_after_meal': (
      '2 hours after starting a meal',
      'بعد ساعتين من بدء الأكل',
    ),
    'check_in_mg': ('mg/dL', 'ملغ/دل'),
    'check_in_mmhg': ('mmHg', 'ملم زئبق'),
    'check_in_number_error': (
      'Enter a positive whole number.',
      'أدخل رقماً صحيحاً أكبر من صفر.',
    ),
    'check_in_pressure_order': (
      'The bottom number must be lower than the top number.',
      'لازم يكون الرقم السفلي أقل من الرقم العلوي.',
    ),
    'check_in_required_reading': (
      'Enter at least one reading.',
      'أدخل قراءة واحدة على الأقل.',
    ),
    'check_in_save': ('Save and compare', 'احفظ وقارن'),
    'check_in_skip': ('Skip for now', 'تخطّي الآن'),
    'check_in_continue': ('Continue to the app', 'تابع إلى التطبيق'),
    'check_in_results': ('Your results', 'نتائج قراءاتك'),
    'check_in_saved': (
      'Your readings are saved on this device.',
      'تم حفظ قراءاتك على هذا الجهاز.',
    ),
    'check_in_first_reading': (
      'This is your first reading of this kind.',
      'هاي أول قراءة من هذا النوع.',
    ),
    'check_in_previous': (
      'Previous: @value · @date, @time',
      'القراءة السابقة: @value · @date، @time',
    ),
    'check_in_previous_sample': (
      'Previous demo reading: @value',
      'القراءة التجريبية السابقة: @value',
    ),
    'check_in_unchanged': ('@label: no change', '@label: بدون تغيير'),
    'check_in_increased': (
      '@label: up @delta @unit',
      '@label: ارتفع @delta @unit',
    ),
    'check_in_decreased': (
      '@label: down @delta @unit',
      '@label: انخفض @delta @unit',
    ),
    'check_in_status_in_range': (
      'Within general reference range',
      'ضمن النطاق المرجعي العام',
    ),
    'check_in_status_below_target': (
      'Below the usual target',
      'أقل من الهدف المعتاد',
    ),
    'check_in_status_low': ('Low reading', 'قراءة منخفضة'),
    'check_in_status_very_low_glucose': (
      'Very low blood sugar',
      'انخفاض شديد في سكر الدم',
    ),
    'check_in_status_above_target': (
      'Above the usual target',
      'أعلى من الهدف المعتاد',
    ),
    'check_in_status_very_high_glucose': (
      'Very high blood sugar',
      'ارتفاع شديد في سكر الدم',
    ),
    'check_in_status_elevated_pressure': (
      'Elevated reading',
      'قراءة مرتفعة قليلاً',
    ),
    'check_in_status_high_pressure': (
      'High reading • stage 1 range',
      'قراءة مرتفعة · نطاق المرحلة الأولى',
    ),
    'check_in_status_very_high_pressure': (
      'High reading • stage 2 range',
      'قراءة مرتفعة · نطاق المرحلة الثانية',
    ),
    'check_in_status_severe_pressure': (
      'Severely high blood pressure',
      'ارتفاع شديد في ضغط الدم',
    ),
    'check_in_low_glucose_note': (
      'Follow your low blood sugar plan now.',
      'اتّبع الآن الخطة التي أعطاك إياها طبيبك للتعامل مع انخفاض السكر.',
    ),
    'check_in_very_low_glucose_note': (
      'Follow your low blood sugar plan now. If you are unable to treat it yourself or are losing consciousness, get emergency help.',
      'اتّبع الآن خطة التعامل مع انخفاض السكر. إذا لم تستطع التعامل معه بنفسك أو بدأت تفقد الوعي، اطلب مساعدة طارئة.',
    ),
    'check_in_very_high_glucose_note': (
      'Seek emergency care if your blood sugar stays at 300 mg/dL or higher, or if you have trouble breathing or cannot keep fluids down.',
      'اطلب رعاية طارئة إذا بقي السكر ٣٠٠ ملغ/دل أو أكثر، أو إذا واجهت صعوبة في التنفس أو لم تستطع الاحتفاظ بالسوائل.',
    ),
    'check_in_low_pressure_note': (
      'If you feel dizzy or unwell, contact your healthcare professional.',
      'إذا شعرت بدوخة أو بتوعّك، تواصل مع طبيبك.',
    ),
    'check_in_severe_pressure_note': (
      'If you have chest pain, trouble breathing, weakness, vision changes, or trouble speaking, call local emergency services now. Otherwise, wait at least a minute and recheck. If it remains this high, contact a healthcare professional promptly.',
      'إذا شعرت بألم في الصدر أو ضيق في التنفس أو ضعف أو تغيّر في النظر أو صعوبة في الكلام، اتصل بالطوارئ المحلية فوراً. بخلاف ذلك، انتظر دقيقة على الأقل وأعد القياس. إذا بقي الضغط مرتفعاً بهذا الشكل، تواصل سريعاً مع طبيبك.',
    ),
    'check_in_reference_note': (
      'These are general adult reference ranges. Follow the targets from your care team. A single reading cannot diagnose a condition.',
      'هذه نطاقات مرجعية عامة للبالغين. اتّبع الأهداف التي حددها طبيبك. قراءة واحدة لا تكفي لتشخيص حالة.',
    ),
    'check_in_load_error': (
      'Could not load your readings. You can retry or continue to the app.',
      'تعذّر تحميل قراءاتك. بإمكانك إعادة المحاولة أو المتابعة إلى التطبيق.',
    ),
    'check_in_save_error': (
      'Could not save on this device. Try again.',
      'تعذّر الحفظ على هذا الجهاز. حاول مرة أخرى.',
    ),
    'check_in_retry': ('Try again', 'حاول مرة أخرى'),
    'trends_title': ('Condition trends', 'متابعة الحالات'),
    'trends_heading': ('Your readings over time', 'قراءاتك مع الوقت'),
    'trends_intro': (
      'Choose a condition to see its chart and recent entries.',
      'اختر حالة لعرض الرسم البياني وآخر القراءات.',
    ),
    'trends_empty': (
      'Log a blood sugar or blood pressure reading to get started.',
      'سجّل قراءة سكر أو ضغط للبدء.',
    ),
    'trends_no_readings': (
      'Your entries will appear here after you log them.',
      'ستظهر قراءاتك هنا بعد تسجيلها.',
    ),
    'trends_log_reading': ('Log a reading', 'سجّل قراءة'),
    'trends_systolic': ('Systolic', 'الانقباضي'),
    'trends_diastolic': ('Diastolic', 'الانبساطي'),
    'trends_change_title': (
      'Large change from the previous entry',
      'تغيّر كبير عن القراءة السابقة',
    ),
    'trends_change_note': (
      'Change alerts highlight differences between entries for review.',
      'تنبيهات التغيّر تلفت انتباهك للفروقات بين القراءات لمراجعتها.',
    ),
    'trends_latest': ('Latest entry', 'آخر تسجيل'),
    'trends_recent': ('Recent entries', 'آخر القراءات'),
    'trends_sample_point': ('Sample', 'تجريبية'),
    'trends_sample_note': (
      'Hollow markers show sample entries.',
      'العلامات المفرغة تمثّل قراءات تجريبية.',
    ),
    'check_in_save_conditions': (
      'Save condition selection',
      'احفظ الحالات المختارة',
    ),
    'tracked_conditions_empty': (
      'Choose diabetes, high blood pressure, or both in Health check-in.',
      'اختَر السكري أو الضغط أو الاثنين من المتابعة الصحية.',
    ),
    'check_in_high_glucose_note': (
      'Drink plain water to stay hydrated if your care team has not limited your fluids. Follow your diabetes care plan if readings stay high.',
      'اشرب مي للحفاظ على الترطيب إذا ما حدّد لك طبيبك كمية السوائل. إذا ظلّ السكر مرتفع، اتّبع خطة المتابعة مع طبيبك.',
    ),
    'check_in_high_pressure_note': (
      'Sit quietly for five minutes, then measure again. Contact your healthcare professional if readings stay high. For daily meals, choose foods with less salt, such as vegetables without added salt.',
      'ارتاح وإنت قاعد خمس دقايق، وبعدين أعد القياس. إذا ظلّ الضغط مرتفع، تواصل مع طبيبك. بوجباتك اليومية، اختَر أكل قليل الملح، مثل الخضار من دون ملح مضاف.',
    ),
    'brand': ('Saha', 'صحة'),
    'auth_title': ('Your health,\nall in one place.', 'صحتك،\nفي مكان واحد.'),
    'auth_subtitle': (
      'Manage your medicines, track conditions, and stay in touch with your care team.',
      'نظّم أدويتك وتابع حالاتك الصحية وتواصل مع فريق الرعاية.',
    ),
    'sign_in': ('Sign in', 'تسجيل الدخول'),
    'sign_up': ('Create account', 'إنشاء حساب'),
    'demo': ('Explore the demo', 'استكشف النسخة التجريبية'),
    'demo_note': (
      'Demo mode · Use sample information',
      'نسخة تجريبية · استخدم بيانات نموذجية',
    ),
    'demo_profile': (
      'This demo uses fictional doctors. Your demo account and check-in readings stay on this device. Other changes last for this session.',
      'تستخدم هذه النسخة أطباء افتراضيين. يبقى حسابك التجريبي وقراءات المتابعة على هذا الجهاز. التغييرات الأخرى تبقى خلال الجلسة.',
    ),
    'name': ('Full name', 'الاسم الكامل'),
    'email': ('Email address', 'البريد الإلكتروني'),
    'password': ('Password', 'كلمة المرور'),
    'show_password': ('Show password', 'إظهار كلمة المرور'),
    'hide_password': ('Hide password', 'إخفاء كلمة المرور'),
    'required': ('Enter a value', 'أدخل قيمة'),
    'invalid_email': (
      'Enter a valid email address',
      'أدخل بريداً إلكترونياً صحيحاً',
    ),
    'invalid_password': (
      'Use at least 6 characters',
      'استخدم ٦ أحرف على الأقل',
    ),
    'invalid_login': (
      'Email or password is incorrect. You can create a demo account here.',
      'البريد أو كلمة المرور غير صحيحة. يمكنك إنشاء حساب تجريبي هنا.',
    ),
    'email_used': (
      'An account with this email already exists.',
      'يوجد حساب بهذا البريد الإلكتروني.',
    ),
    'demo_name': ('Noor', 'نور'),
    'home': ('Home', 'الرئيسية'),
    'health': ('My health', 'صحتي'),
    'doctors': ('Doctors', 'الأطباء'),
    'messages': ('Messages', 'الرسائل'),
    'profile': ('Profile', 'حسابي'),
    'greeting': ('Hello, @name', 'مرحباً، @name'),
    'daily_plan': ('Today’s care plan', 'خطة الرعاية اليوم'),
    'progress': (
      '@done of @total tasks complete',
      'اكتمل @done من @total مهام',
    ),
    'plan_empty': (
      'Add a reminder to start your plan.',
      'أضف تذكيراً لبدء خطتك.',
    ),
    'daily_schedule': ('Today’s reminders', 'تذكيرات اليوم'),
    'reminders': ('Reminders', 'التذكيرات'),
    'reminder': ('Care reminder', 'تذكير بالرعاية'),
    'due': ('Due', 'حان الموعد'),
    'upcoming': ('Upcoming', 'قادم'),
    'done': ('Done', 'تم'),
    'mark_done': ('Mark as done', 'تحديد كمكتمل'),
    'undo_done': ('Undo completion', 'التراجع عن الإكمال'),
    'empty_reminders': (
      'Your scheduled medicines and health actions will appear here.',
      'ستظهر هنا مواعيد الأدوية والمهام الصحية.',
    ),
    'quick_actions': ('Quick actions', 'اختصارات'),
    'add_medicine': ('Add medicine', 'إضافة دواء'),
    'find_doctor': ('Find a doctor', 'ابحث عن طبيب'),
    'appointments': ('Appointments', 'المواعيد'),
    'next_visit': ('Next appointment', 'الموعد القادم'),
    'health_intro': (
      'Manage your conditions, medicines, and daily routines.',
      'أدر حالاتك الصحية وأدويتك وروتينك اليومي.',
    ),
    'conditions': ('Conditions', 'الحالات الصحية'),
    'medicines': ('Medicines', 'الأدوية'),
    'empty_medicines': (
      'Add a medicine to put it on your daily schedule.',
      'أضف دواءً لإدراجه في جدولك اليومي.',
    ),
    'medicine_name': ('Medicine name', 'اسم الدواء'),
    'dose': ('Dose or instructions', 'الجرعة أو التعليمات'),
    'dose_hint': ('As prescribed', 'حسب الوصفة'),
    'daily_reminder': ('Daily reminder', 'تذكير يومي'),
    'reminder_time': ('Reminder time', 'وقت التذكير'),
    'edit_medicine': ('Edit medicine', 'تعديل الدواء'),
    'edit': ('Edit', 'تعديل'),
    'delete': ('Delete', 'حذف'),
    'delete_record': ('Delete this record?', 'هل تريد حذف هذا السجل؟'),
    'delete_record_body': (
      'This also removes its daily reminder.',
      'سيؤدي ذلك أيضاً إلى حذف التذكير اليومي المرتبط به.',
    ),
    'cancel': ('Cancel', 'إلغاء'),
    'save': ('Save', 'حفظ'),
    'all': ('All', 'الكل'),
    'doctor_intro': (
      'Browse specialties and choose a time that works for you.',
      'تصفّح التخصصات واختر موعداً يناسبك.',
    ),
    'search_doctors': ('Search doctors or specialties', 'ابحث عن طبيب أو تخصص'),
    'no_doctors': (
      'No doctors match your search.',
      'لا يوجد أطباء يطابقون البحث.',
    ),
    'book': ('Book appointment', 'احجز موعداً'),
    'view_doctor': ('View profile', 'عرض الملف'),
    'chat': ('Message', 'مراسلة'),
    'about': ('About', 'نبذة'),
    'available_times': ('Available times', 'الأوقات المتاحة'),
    'choose_date': ('Choose a date', 'اختر تاريخاً'),
    'choose_time': ('Choose a time', 'اختر وقتاً'),
    'no_slots': (
      'All times are booked for this date.',
      'جميع الأوقات محجوزة لهذا اليوم.',
    ),
    'confirm_booking': ('Confirm appointment', 'تأكيد الموعد'),
    'booking_confirmed': ('Demo appointment booked', 'تم حجز الموعد التجريبي'),
    'upcoming_appointments': ('Upcoming appointments', 'المواعيد القادمة'),
    'past_appointments': ('Past appointments', 'المواعيد السابقة'),
    'empty_appointments': (
      'Book a visit to see it here.',
      'احجز زيارة لتظهر هنا.',
    ),
    'cancel_visit': ('Cancel appointment', 'إلغاء الموعد'),
    'cancel_visit_title': (
      'Cancel this appointment?',
      'هل تريد إلغاء هذا الموعد؟',
    ),
    'keep_visit': ('Keep appointment', 'الاحتفاظ بالموعد'),
    'clinic_visit': ('In-person visit', 'زيارة في العيادة'),
    'family': ('Family medicine', 'طب الأسرة'),
    'cardiology': ('Cardiology', 'أمراض القلب'),
    'dermatology': ('Dermatology', 'الأمراض الجلدية'),
    'physiotherapy': ('Physical therapy', 'العلاج الطبيعي'),
    'maya': ('Maya Awad, Physiotherapist', 'مايا عوّاد، أخصائية علاج طبيعي'),
    'maya_clinic': ('Cedar Rehabilitation Clinic', 'عيادة الأرز للتأهيل'),
    'maya_bio': (
      'Maya offers physical therapy appointments focused on movement and rehabilitation.',
      'تقدّم مايا جلسات علاج طبيعي تركّز على الحركة والتأهيل.',
    ),
    'lina': ('Dr. Lina Haddad', 'د. لينا حداد'),
    'omar': ('Dr. Omar Khalil', 'د. عمر خليل'),
    'sara': ('Dr. Sara Nasser', 'د. سارة ناصر'),
    'lina_clinic': ('Olive Family Clinic', 'عيادة الزيتون لطب الأسرة'),
    'omar_clinic': ('Amman Heart Centre', 'مركز عمّان للقلب'),
    'sara_clinic': ('Cedar Skin Clinic', 'عيادة الأرز للجلدية'),
    'lina_bio': (
      'Dr. Lina offers routine checkups and follow-up visits for adults and families.',
      'تقدم د. لينا الفحوصات الدورية وزيارات المتابعة للبالغين والعائلات.',
    ),
    'omar_bio': (
      'Dr. Omar provides consultations and follow-up visits for heart health.',
      'يقدم د. عمر استشارات وزيارات متابعة لصحة القلب.',
    ),
    'sara_bio': (
      'Dr. Sara offers consultations for skin and hair concerns.',
      'تقدم د. سارة استشارات لمشكلات البشرة والشعر.',
    ),
    'chat_intro': (
      'Your conversations with the care team.',
      'محادثاتك مع فريق الرعاية.',
    ),
    'demo_chat': ('Simulated conversation', 'محادثة تجريبية'),
    'chat_welcome': (
      'Hello! You can use this demo conversation to try messaging before a visit.',
      'مرحباً! يمكنك تجربة المراسلة قبل الزيارة في هذه المحادثة التجريبية.',
    ),
    'chat_reply': (
      'Thanks for trying the demo. In the live app, your care team would reply here.',
      'شكراً لتجربة التطبيق. في النسخة الفعلية، سيرد فريق الرعاية هنا.',
    ),
    'message_hint': ('Write a message…', 'اكتب رسالة…'),
    'send': ('Send message', 'إرسال الرسالة'),
    'empty_chat': (
      'Open a doctor’s profile to start a conversation.',
      'افتح ملف الطبيب لبدء محادثة.',
    ),
    'language': ('Language', 'اللغة'),
    'english': ('English', 'English'),
    'arabic': ('العربية', 'العربية'),
    'sign_out': ('Sign out', 'تسجيل الخروج'),
    'demo_account': ('Demo account', 'حساب تجريبي'),
    'demo_med_1': ('Morning medicine', 'دواء الصباح'),
    'demo_med_2': ('Evening medicine', 'دواء المساء'),
  };

  @override
  Map<String, Map<String, String>> get keys => {
    'en': _copy.map((key, text) => MapEntry(key, text.$1)),
    'ar': _copy.map((key, text) => MapEntry(key, text.$2)),
  };
}
