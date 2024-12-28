package app_music.demo.Utils;

import org.apache.commons.codec.binary.Base64;
import org.bouncycastle.bcpg.ArmoredOutputStream;
import org.bouncycastle.openpgp.*;
import org.bouncycastle.openpgp.operator.jcajce.*;

import java.io.*;
import java.security.*;
import java.util.Date;

public class PGPUtils {

    private static final String PROVIDER = "BC";
    private static final int PGP_KEY_SIZE = 2048;

    static {
        Security.addProvider(new org.bouncycastle.jce.provider.BouncyCastleProvider());
    }

    public static String encryptPassword(String password, PGPPublicKey publicKey) throws PGPException, IOException {
        return encrypt(password, publicKey);
    }

    public static String decryptPassword(String encryptedPassword, PGPPrivateKey privateKey) throws PGPException, IOException {
        return decrypt(encryptedPassword, privateKey);
    }

    public static String encryptVerificationCode(String code, PGPPublicKey publicKey) throws PGPException, IOException {
        return encrypt(code, publicKey);
    }

    public static String decryptVerificationCode(String encryptedCode, PGPPrivateKey privateKey) throws PGPException, IOException {
        return decrypt(encryptedCode, privateKey);
    }

    private static String encrypt(String data, PGPPublicKey publicKey) throws PGPException, IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (ArmoredOutputStream armoredOut = new ArmoredOutputStream(out)) {
            PGPEncryptedDataGenerator encryptGen = new PGPEncryptedDataGenerator(
                    new JcePGPDataEncryptorBuilder(PGPEncryptedData.CAST5)
                            .setWithIntegrityPacket(true)
                            .setSecureRandom(new SecureRandom())
                            .setProvider(PROVIDER));
            encryptGen.addMethod(new JcePublicKeyKeyEncryptionMethodGenerator(publicKey).setProvider(PROVIDER));
            try (OutputStream cOut = encryptGen.open(armoredOut, new byte[4096])) {
                PGPCompressedDataGenerator compressGen = new PGPCompressedDataGenerator(PGPCompressedData.ZIP);
                try (OutputStream compressOut = compressGen.open(cOut)) {
                    PGPLiteralDataGenerator literalGen = new PGPLiteralDataGenerator();
                    try (OutputStream literalOut = literalGen.open(compressOut,
                            PGPLiteralData.BINARY,
                            PGPLiteralData.CONSOLE,
                            data.getBytes().length,
                            new Date())) {
                        literalOut.write(data.getBytes());
                    }
                }
            }
        }
        return Base64.encodeBase64String(out.toByteArray());
    }

    private static String decrypt(String encryptedData, PGPPrivateKey privateKey) throws PGPException, IOException {
        byte[] data = Base64.decodeBase64(encryptedData);
        try (ByteArrayInputStream in = new ByteArrayInputStream(data);
             InputStream armorIn = PGPUtil.getDecoderStream(in)) {
            PGPObjectFactory factory = new PGPObjectFactory(armorIn, new JcaKeyFingerprintCalculator());
            Object o = factory.nextObject();
            if (o instanceof PGPEncryptedDataList) {
                PGPEncryptedDataList encDataList = (PGPEncryptedDataList) o;
                PGPPublicKeyEncryptedData encData = (PGPPublicKeyEncryptedData) encDataList.getEncryptedDataObjects().next();
                InputStream clearData = encData.getDataStream(new JcePublicKeyDataDecryptorFactoryBuilder().setProvider(PROVIDER).build(privateKey));
                PGPObjectFactory clearFactory = new PGPObjectFactory(clearData, new JcaKeyFingerprintCalculator());
                PGPCompressedData compressedData = (PGPCompressedData) clearFactory.nextObject();
                PGPObjectFactory literalFactory = new PGPObjectFactory(compressedData.getDataStream(), new JcaKeyFingerprintCalculator());
                PGPLiteralData literalData = (PGPLiteralData) literalFactory.nextObject();
                try (InputStream literalIn = literalData.getInputStream()) {
                    ByteArrayOutputStream literalOut = new ByteArrayOutputStream();
                    int ch;
                    while ((ch = literalIn.read()) >= 0) {
                        literalOut.write(ch);
                    }
                    return literalOut.toString();
                }
            } else {
                throw new PGPException("Encrypted data is not an instance of PGPEncryptedDataList");
            }
        }
    }

    public static PGPKeyPair generateKeyPair() throws PGPException, NoSuchAlgorithmException, NoSuchProviderException {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA", PROVIDER);
        keyGen.initialize(PGP_KEY_SIZE);
        KeyPair keyPair = keyGen.generateKeyPair();
        return new JcaPGPKeyPair(PGPPublicKey.RSA_GENERAL, keyPair, new Date());
    }
}
