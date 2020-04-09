package flutter.plugins.contactsservice.contactsservice;

import static android.provider.ContactsContract.CommonDataKinds;
import static android.provider.ContactsContract.CommonDataKinds.Email;
import static android.provider.ContactsContract.CommonDataKinds.Organization;
import static android.provider.ContactsContract.CommonDataKinds.Phone;
import static android.provider.ContactsContract.CommonDataKinds.StructuredName;
import static android.provider.ContactsContract.CommonDataKinds.StructuredPostal;

import android.annotation.TargetApi;
import android.content.ContentProviderOperation;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.BaseColumns;
import android.provider.ContactsContract;
import android.provider.ContactsContract.RawContacts;
import android.text.TextUtils;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

@TargetApi(Build.VERSION_CODES.ECLAIR)
public class ContactsServicePlugin implements MethodCallHandler {

  ContactsServicePlugin(ContentResolver contentResolver){
    this.contentResolver = contentResolver;
  }

  private static final String LOG_TAG = "flutter_contacts";
  private final ContentResolver contentResolver;
  private final ExecutorService executor =
      new ThreadPoolExecutor(0, 10, 60, TimeUnit.SECONDS, new ArrayBlockingQueue<Runnable>(1000));

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "github.com/clovisnicolas/flutter_contacts");
    channel.setMethodCallHandler(new ContactsServicePlugin(registrar.context().getContentResolver()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method){
      case "getContacts": {
        this.getContacts((String)call.argument("query"), (boolean)call.argument("withThumbnails"), (boolean)call.argument("photoHighResolution"), (boolean)call.argument("orderByGivenName"), result);
        break;
      } case "getContactsForPhone": {
        this.getContactsForPhone((String)call.argument("phone"), (boolean)call.argument("withThumbnails"), (boolean)call.argument("photoHighResolution"), (boolean)call.argument("orderByGivenName"), result);
        break;
      } case "getAvatar": {
        final Contact contact = Contact.fromMap((HashMap)call.argument("contact"));
        this.getAvatar(contact, (boolean)call.argument("photoHighResolution"), result);
        break;
      } case "addContact": {
        final Contact contact = Contact.fromMap((HashMap)call.arguments);
        if (this.addContact(contact)) {
          result.success(null);
        } else {
          result.error(null, "Failed to add the contact", null);
        }
        break;
      } case "deleteContact": {
        final Contact contact = Contact.fromMap((HashMap)call.arguments);
        if (this.deleteContact(contact)) {
          result.success(null);
        } else {
          result.error(null, "Failed to delete the contact, make sure it has a valid identifier", null);
        }
        break;
      } case "updateContact": {
        final Contact contact = Contact.fromMap((HashMap)call.arguments);
        if (this.updateContact(contact)) {
          result.success(null);
        } else {
          result.error(null, "Failed to update the contact, make sure it has a valid identifier", null);
        }
        break;
      } default: {
        result.notImplemented();
        break;
      }
    }
  }

  private static final String[] PROJECTION =
          {
                  ContactsContract.Data.CONTACT_ID,
                  ContactsContract.Profile.DISPLAY_NAME,
                  ContactsContract.Contacts.Data.MIMETYPE,
                  ContactsContract.RawContacts.ACCOUNT_TYPE,
                  ContactsContract.RawContacts.ACCOUNT_NAME,
                  StructuredName.DISPLAY_NAME,
                  StructuredName.GIVEN_NAME,
                  StructuredName.MIDDLE_NAME,
                  StructuredName.FAMILY_NAME,
                  StructuredName.PREFIX,
                  StructuredName.SUFFIX,
                  CommonDataKinds.Note.NOTE,
                  Phone.NUMBER,
                  Phone.TYPE,
                  Phone.LABEL,
                  Email.DATA,
                  Email.ADDRESS,
                  Email.TYPE,
                  Email.LABEL,
                  Organization.COMPANY,
                  Organization.TITLE,
                  StructuredPostal.FORMATTED_ADDRESS,
                  StructuredPostal.TYPE,
                  StructuredPostal.LABEL,
                  StructuredPostal.STREET,
                  StructuredPostal.POBOX,
                  StructuredPostal.NEIGHBORHOOD,
                  StructuredPostal.CITY,
                  StructuredPostal.REGION,
                  StructuredPostal.POSTCODE,
                  StructuredPostal.COUNTRY,
          };


  @TargetApi(Build.VERSION_CODES.ECLAIR)
  private void getContacts(String query, boolean withThumbnails, boolean photoHighResolution, boolean orderByGivenName, Result result) {
    new GetContactsTask(result, withThumbnails, photoHighResolution, orderByGivenName).executeOnExecutor(executor, query, false);
  }

  private void getContactsForPhone(String phone, boolean withThumbnails, boolean photoHighResolution, boolean orderByGivenName, Result result) {
    new GetContactsTask(result, withThumbnails, photoHighResolution, orderByGivenName).executeOnExecutor(executor, phone, true);
  }

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  private class GetContactsTask extends AsyncTask<Object, Void, ArrayList<HashMap>> {

    private Result getContactResult;
    private boolean withThumbnails;
    private boolean photoHighResolution;
    private boolean orderByGivenName;

    public GetContactsTask(Result result, boolean withThumbnails, boolean photoHighResolution, boolean orderByGivenName){
      this.getContactResult = result;
      this.withThumbnails = withThumbnails;
      this.photoHighResolution = photoHighResolution;
      this.orderByGivenName = orderByGivenName;
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    protected ArrayList<HashMap> doInBackground(Object... params) {
      ArrayList<Contact> contacts;
      if ((Boolean) params[1])
        contacts = getContactsFromFast(getCursorForPhone(((String) params[0])));
      else
        contacts = getContactsFromFast(getCursor(((String) params[0])));

      if (withThumbnails) {
        for(Contact c : contacts){
          final byte[] avatar = loadContactPhotoHighRes(
              c.identifier, photoHighResolution, contentResolver);
          if (avatar != null) {
            c.avatar = avatar;
          } else {
            // To stay backwards-compatible, return an empty byte array rather than `null`.
            c.avatar = new byte[0];
          }
//          if ((Boolean) params[3])
//              loadContactPhotoHighRes(c.identifier, (Boolean) params[3]);
//          else
//              setAvatarDataForContactIfAvailable(c);
        }
      }

      if (orderByGivenName)
      {
        Comparator<Contact> compareByGivenName = new Comparator<Contact>() {
          @Override
          public int compare(Contact contactA, Contact contactB) {
            return contactA.compareTo(contactB);
          }
        };
        Collections.sort(contacts,compareByGivenName);
      }

      //Transform the list of contacts to a list of Map
      ArrayList<HashMap> contactMaps = new ArrayList<>();
      for(Contact c : contacts){
        contactMaps.add(c.toMap());
      }

      return contactMaps;
    }

    protected void onPostExecute(ArrayList<HashMap> result) {
      getContactResult.success(result);
    }
  }


  private Cursor getCursor(String query) {
    String selection = ContactsContract.Data.MIMETYPE + "=? OR " + ContactsContract.Data.MIMETYPE + "=? OR "
        + ContactsContract.Data.MIMETYPE + "=? OR " + ContactsContract.Data.MIMETYPE + "=? OR "
        + ContactsContract.Data.MIMETYPE + "=? OR " + ContactsContract.Data.MIMETYPE + "=? OR "
        + ContactsContract.Data.MIMETYPE + "=? OR " + ContactsContract.RawContacts.ACCOUNT_TYPE + "=?";
    String[] selectionArgs = new String[] { CommonDataKinds.Note.CONTENT_ITEM_TYPE, Email.CONTENT_ITEM_TYPE,
        Phone.CONTENT_ITEM_TYPE, StructuredName.CONTENT_ITEM_TYPE, Organization.CONTENT_ITEM_TYPE,
        StructuredPostal.CONTENT_ITEM_TYPE, CommonDataKinds.Event.CONTENT_ITEM_TYPE, ContactsContract.RawContacts.ACCOUNT_TYPE
    };
    if(query != null){
      selectionArgs = new String[]{query + "%"};
      selection = ContactsContract.Contacts.DISPLAY_NAME_PRIMARY + " LIKE ?";
    }

    return contentResolver.query(ContactsContract.Data.CONTENT_URI, PROJECTION, selection, selectionArgs, null);
  }
  private Cursor getCursorForPhone(String phone) {
    if (phone.isEmpty())
      return null;

    Uri uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phone));
    String[] projection = new String[]{BaseColumns._ID};

    ArrayList<String> contactIds = new ArrayList<>();
    Cursor phoneCursor = contentResolver.query(uri, projection, null, null, null);
    while (phoneCursor != null && phoneCursor.moveToNext()){
      contactIds.add(phoneCursor.getString(phoneCursor.getColumnIndex(BaseColumns._ID)));
    }
    if (phoneCursor!= null)
      phoneCursor.close();

    if (!contactIds.isEmpty()) {
      String contactIdsListString = contactIds.toString().replace("[", "(").replace("]", ")");
      String contactSelection = ContactsContract.Data.CONTACT_ID + " IN " + contactIdsListString;
      return contentResolver.query(ContactsContract.Data.CONTENT_URI, PROJECTION, contactSelection, null, null);
    }

    return null;
  }

  /**
   * Builds the list of contacts from the cursor
   * @param cursor
   * @return the list of contacts
   */
  private ArrayList<Contact> getContactsFrom(Cursor cursor) {
    HashMap<String, Contact> map = new LinkedHashMap<>();

    while (cursor != null && cursor.moveToNext()) {
      int columnIndex = cursor.getColumnIndex(ContactsContract.Data.CONTACT_ID);
      String contactId = cursor.getString(columnIndex);

      if (!map.containsKey(contactId)) {
        map.put(contactId, new Contact(contactId));
      }
      Contact contact = map.get(contactId);

      String mimeType = cursor.getString(cursor.getColumnIndex(ContactsContract.Data.MIMETYPE));
      contact.displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
      contact.androidAccountType = cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_TYPE));
      contact.androidAccountName = cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_NAME));

      //NAMES
      if (mimeType.equals(CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)) {
        contact.givenName = cursor.getString(cursor.getColumnIndex(StructuredName.GIVEN_NAME));
        contact.middleName = cursor.getString(cursor.getColumnIndex(StructuredName.MIDDLE_NAME));
        contact.familyName = cursor.getString(cursor.getColumnIndex(StructuredName.FAMILY_NAME));
        contact.prefix = cursor.getString(cursor.getColumnIndex(StructuredName.PREFIX));
        contact.suffix = cursor.getString(cursor.getColumnIndex(StructuredName.SUFFIX));
      }
      // NOTE
      else if (mimeType.equals(CommonDataKinds.Note.CONTENT_ITEM_TYPE)) {
        contact.note = cursor.getString(cursor.getColumnIndex(CommonDataKinds.Note.NOTE));
      }
      //PHONES
      else if (mimeType.equals(CommonDataKinds.Phone.CONTENT_ITEM_TYPE)){
        String phoneNumber = cursor.getString(cursor.getColumnIndex(Phone.NUMBER));
        int type = cursor.getInt(cursor.getColumnIndex(Phone.TYPE));
        if (!TextUtils.isEmpty(phoneNumber)){
          contact.phones.add(new Item(Item.getPhoneLabel(type),phoneNumber));
        }
      }
      //MAILS
      else if (mimeType.equals(CommonDataKinds.Email.CONTENT_ITEM_TYPE)) {
        String email = cursor.getString(cursor.getColumnIndex(Email.ADDRESS));
        int type = cursor.getInt(cursor.getColumnIndex(Email.TYPE));
        if (!TextUtils.isEmpty(email)) {
          contact.emails.add(new Item(Item.getEmailLabel(type, cursor),email));
        }
      }
      //ORG
      else if (mimeType.equals(CommonDataKinds.Organization.CONTENT_ITEM_TYPE)) {
        contact.company = cursor.getString(cursor.getColumnIndex(Organization.COMPANY));
        contact.jobTitle = cursor.getString(cursor.getColumnIndex(Organization.TITLE));
      }
      //ADDRESSES
      else if (mimeType.equals(CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)) {
        contact.postalAddresses.add(new PostalAddress(cursor));
      }
      // BIRTHDAY
      else if (mimeType.equals(CommonDataKinds.Event.CONTENT_ITEM_TYPE)) {
        int eventType = cursor.getInt(cursor.getColumnIndex(CommonDataKinds.Event.TYPE));
        if (eventType == CommonDataKinds.Event.TYPE_BIRTHDAY) {
          contact.birthday = cursor.getString(cursor.getColumnIndex(CommonDataKinds.Event.START_DATE));
        }
      }
    }

    if(cursor != null)
      cursor.close();

    return new ArrayList<>(map.values());
  }
  /**
   * Builds the fast list of contacts from the cursor
   * @param cursor
   * @return the list of contacts
   */
  private ArrayList<Contact> getContactsFromFast(Cursor cursor) {
    HashMap<String, Contact> map = new LinkedHashMap<>();

    while (cursor != null && cursor.moveToNext()) {
      int columnIndex = cursor.getColumnIndex(ContactsContract.Data.CONTACT_ID);
      String contactId = cursor.getString(columnIndex);

      if (!map.containsKey(contactId)) {
        map.put(contactId, new Contact(contactId));
      }
      Contact contact = map.get(contactId);

      String mimeType = cursor.getString(cursor.getColumnIndex(ContactsContract.Data.MIMETYPE));
      contact.displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
      contact.androidAccountType = cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_TYPE));
      contact.androidAccountName = cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_NAME));

      //NAMES
      if (mimeType.equals(CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)) {
        contact.givenName = cursor.getString(cursor.getColumnIndex(StructuredName.GIVEN_NAME));
        contact.middleName = cursor.getString(cursor.getColumnIndex(StructuredName.MIDDLE_NAME));
        contact.familyName = cursor.getString(cursor.getColumnIndex(StructuredName.FAMILY_NAME));
        contact.prefix = cursor.getString(cursor.getColumnIndex(StructuredName.PREFIX));
        contact.suffix = cursor.getString(cursor.getColumnIndex(StructuredName.SUFFIX));
      }
      //PHONES
      else if (mimeType.equals(CommonDataKinds.Phone.CONTENT_ITEM_TYPE)){
        String phoneNumber = cursor.getString(cursor.getColumnIndex(Phone.NUMBER));
        int type = cursor.getInt(cursor.getColumnIndex(Phone.TYPE));
        if (!TextUtils.isEmpty(phoneNumber)){
          contact.phones.add(new Item(Item.getPhoneLabel(type),phoneNumber));
        }
      }
    }

    if(cursor != null)
      cursor.close();

    return new ArrayList<>(map.values());
  }

  private void setAvatarDataForContactIfAvailable(Contact contact) {
    Uri contactUri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, Integer.parseInt(contact.identifier));
    Uri photoUri = Uri.withAppendedPath(contactUri, ContactsContract.Contacts.Photo.CONTENT_DIRECTORY);
    Cursor avatarCursor = contentResolver.query(photoUri,
            new String[] {ContactsContract.Contacts.Photo.PHOTO}, null, null, null);
    if (avatarCursor != null && avatarCursor.moveToFirst()) {
      byte[] avatar = avatarCursor.getBlob(0);
      contact.avatar = avatar;
    }
    if (avatarCursor != null) {
      avatarCursor.close();
    }
  }

  private void getAvatar(final Contact contact, final boolean highRes,
      final Result result) {
    new GetAvatarsTask(contact, highRes, contentResolver, result).executeOnExecutor(this.executor);
  }

  private static class GetAvatarsTask extends AsyncTask<Void, Void, byte[]> {
    final Contact contact;
    final boolean highRes;
    final ContentResolver contentResolver;
    final Result result;

    GetAvatarsTask(final Contact contact, final boolean highRes,
        final ContentResolver contentResolver, final Result result) {
      this.contact = contact;
      this.highRes = highRes;
      this.contentResolver = contentResolver;
      this.result = result;
    }

    @Override
    protected byte[] doInBackground(final Void... params) {
      // Load avatar for each contact identifier.
      return loadContactPhotoHighRes(contact.identifier, highRes, contentResolver);
    }

    @Override
    protected void onPostExecute(final byte[] avatar) {
      result.success(avatar);
    }
  }

  private static byte[] loadContactPhotoHighRes(final String identifier,
      final boolean photoHighResolution, final ContentResolver contentResolver) {
    try {
      final Uri uri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, Long.parseLong(identifier));
      final InputStream input = ContactsContract.Contacts.openContactPhotoInputStream(contentResolver, uri, photoHighResolution);

      if (input == null) return null;

      final Bitmap bitmap = BitmapFactory.decodeStream(input);
      input.close();

      final ByteArrayOutputStream stream = new ByteArrayOutputStream();
      bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
      final byte[] bytes = stream.toByteArray();
      stream.close();
      return bytes;
    } catch (final IOException ex){
      Log.e(LOG_TAG, ex.getMessage());
      return null;
    }
  }

  private boolean addContact(Contact contact){

    ArrayList<ContentProviderOperation> ops = new ArrayList<>();

    ContentProviderOperation.Builder op = ContentProviderOperation.newInsert(ContactsContract.RawContacts.CONTENT_URI)
            .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, null)
            .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, null);
    ops.add(op.build());

    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
            .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
            .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
            .withValue(StructuredName.GIVEN_NAME, contact.givenName)
            .withValue(StructuredName.MIDDLE_NAME, contact.middleName)
            .withValue(StructuredName.FAMILY_NAME, contact.familyName)
            .withValue(StructuredName.PREFIX, contact.prefix)
            .withValue(StructuredName.SUFFIX, contact.suffix);
    ops.add(op.build());

    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
            .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
            .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Note.CONTENT_ITEM_TYPE)
            .withValue(CommonDataKinds.Note.NOTE, contact.note);
    ops.add(op.build());

    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
            .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
            .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
            .withValue(Organization.COMPANY, contact.company)
            .withValue(Organization.TITLE, contact.jobTitle);
    ops.add(op.build());

    //Photo
    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
            .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
            .withValue(ContactsContract.Data.IS_SUPER_PRIMARY, 1)
            .withValue(ContactsContract.CommonDataKinds.Photo.PHOTO, contact.avatar)
            .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE);
    ops.add(op.build());

    op.withYieldAllowed(true);

    //Phones
    for(Item phone : contact.phones){
      op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
              .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
              .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
              .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, phone.value);

      if (Item.stringToPhoneType(phone.label) == ContactsContract.CommonDataKinds.Phone.TYPE_CUSTOM){
        op.withValue( ContactsContract.CommonDataKinds.Phone.TYPE, ContactsContract.CommonDataKinds.BaseTypes.TYPE_CUSTOM );
        op.withValue(ContactsContract.CommonDataKinds.Phone.LABEL, phone.label);
      } else
        op.withValue( ContactsContract.CommonDataKinds.Phone.TYPE, Item.stringToPhoneType(phone.label) );

      ops.add(op.build());
    }

    //Emails
    for (Item email : contact.emails) {
      op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
              .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
              .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Email.CONTENT_ITEM_TYPE)
              .withValue(CommonDataKinds.Email.ADDRESS, email.value)
              .withValue(CommonDataKinds.Email.TYPE, Item.stringToEmailType(email.label));
      ops.add(op.build());
    }
    //Postal addresses
    for (PostalAddress address : contact.postalAddresses) {
      op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
              .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
              .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)
              .withValue(CommonDataKinds.StructuredPostal.TYPE, PostalAddress.stringToPostalAddressType(address.label))
              .withValue(CommonDataKinds.StructuredPostal.LABEL, address.label)
              .withValue(CommonDataKinds.StructuredPostal.STREET, address.street)
              .withValue(CommonDataKinds.StructuredPostal.CITY, address.city)
              .withValue(CommonDataKinds.StructuredPostal.REGION, address.region)
              .withValue(CommonDataKinds.StructuredPostal.POSTCODE, address.postcode)
              .withValue(CommonDataKinds.StructuredPostal.COUNTRY, address.country);
      ops.add(op.build());
    }

    try {
      contentResolver.applyBatch(ContactsContract.AUTHORITY, ops);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  private boolean deleteContact(Contact contact){
    ArrayList<ContentProviderOperation> ops = new ArrayList<>();
    ops.add(ContentProviderOperation.newDelete(ContactsContract.RawContacts.CONTENT_URI)
            .withSelection(ContactsContract.RawContacts.CONTACT_ID + "=?", new String[]{String.valueOf(contact.identifier)})
            .build());
    try {
      contentResolver.applyBatch(ContactsContract.AUTHORITY, ops);
      return true;
    } catch (Exception e) {
      return false;

    }
  }

  private boolean updateContact(Contact contact) {
    ArrayList<ContentProviderOperation> ops = new ArrayList<>();
    ContentProviderOperation.Builder op;

    // Drop all details about contact except name
    op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE});
    ops.add(op.build());

    op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE});
    ops.add(op.build());

    op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID +"=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE});
    ops.add(op.build());

    op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID +"=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE});
    ops.add(op.build());

    op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE});
    ops.add(op.build());

    //Photo
    op = ContentProviderOperation.newDelete(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE});
    ops.add(op.build());

    // Update data (name)
    op = ContentProviderOperation.newUpdate(ContactsContract.Data.CONTENT_URI)
            .withSelection(ContactsContract.Data.CONTACT_ID + "=? AND " + ContactsContract.Data.MIMETYPE + "=?",
                    new String[]{String.valueOf(contact.identifier), ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE})
            .withValue(StructuredName.GIVEN_NAME, contact.givenName)
            .withValue(StructuredName.MIDDLE_NAME, contact.middleName)
            .withValue(StructuredName.FAMILY_NAME, contact.familyName)
            .withValue(StructuredName.PREFIX, contact.prefix)
            .withValue(StructuredName.SUFFIX, contact.suffix);
    ops.add(op.build());

    // Insert data back into contact
    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
            .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
            .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
            .withValue(Organization.TYPE, Organization.TYPE_WORK)
            .withValue(Organization.COMPANY, contact.company)
            .withValue(Organization.TITLE, contact.jobTitle);
    ops.add(op.build());

    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
            .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE)
            .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
            .withValue(CommonDataKinds.Note.NOTE, contact.note);
    ops.add(op.build());

    //Photo
    op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
          .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
          .withValue(ContactsContract.Data.IS_SUPER_PRIMARY, 1)
          .withValue(ContactsContract.CommonDataKinds.Photo.PHOTO, contact.avatar)
          .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE);
    ops.add(op.build());


    for (Item phone : contact.phones) {
      op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
              .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
              .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
              .withValue(Phone.NUMBER, phone.value);

      if (Item.stringToPhoneType(phone.label) == ContactsContract.CommonDataKinds.Phone.TYPE_CUSTOM){
        op.withValue( ContactsContract.CommonDataKinds.Phone.TYPE, ContactsContract.CommonDataKinds.BaseTypes.TYPE_CUSTOM );
        op.withValue(ContactsContract.CommonDataKinds.Phone.LABEL, phone.label);
      } else
        op.withValue( ContactsContract.CommonDataKinds.Phone.TYPE, Item.stringToPhoneType(phone.label) );

      ops.add(op.build());
    }

    for (Item email : contact.emails) {
      op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
              .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Email.CONTENT_ITEM_TYPE)
              .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
              .withValue(CommonDataKinds.Email.ADDRESS, email.value)
              .withValue(CommonDataKinds.Email.TYPE, Item.stringToEmailType(email.label));
      ops.add(op.build());
    }

    for (PostalAddress address : contact.postalAddresses) {
      op = ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
              .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)
              .withValue(ContactsContract.Data.RAW_CONTACT_ID, contact.identifier)
              .withValue(CommonDataKinds.StructuredPostal.TYPE, PostalAddress.stringToPostalAddressType(address.label))
              .withValue(CommonDataKinds.StructuredPostal.STREET, address.street)
              .withValue(CommonDataKinds.StructuredPostal.CITY, address.city)
              .withValue(CommonDataKinds.StructuredPostal.REGION, address.region)
              .withValue(CommonDataKinds.StructuredPostal.POSTCODE, address.postcode)
              .withValue(CommonDataKinds.StructuredPostal.COUNTRY, address.country);
      ops.add(op.build());
    }

    try {
      contentResolver.applyBatch(ContactsContract.AUTHORITY, ops);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

}
