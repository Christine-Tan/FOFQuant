package matlabtool;

import com.mathworks.toolbox.javabuilder.MWClassID;
import com.mathworks.toolbox.javabuilder.MWComplexity;
import com.mathworks.toolbox.javabuilder.MWNumericArray;

import java.util.List;

/**
 * Created by Daniel on 2016/8/18.
 */
public class TypeConverter {

    public static <T> MWNumericArray convertList(List<T> numbers) {
        int len = numbers.size();
        MWNumericArray array = MWNumericArray.newInstance(new int[]{1, len}, MWClassID.DOUBLE,
                MWComplexity.REAL);
        for (int i = 0; i < len; i++) {
            array.set(i + 1, numbers.get(i));
        }
        return array;
    }

    public static double getSingleDoubleResult(Object[] objs) {
        MWNumericArray mwNumericArray = (MWNumericArray) objs[0];
        return mwNumericArray.getDouble(1);
    }

    public static double[] getDoubleResults(Object[] objs, int resultNumber) {
        double[] result = new double[resultNumber];
        for (int i = 0; i < resultNumber; i++) {
            result[i] = ((MWNumericArray) objs[i]).getDouble(1);
        }
        return result;
    }

    public static double[] getDoubleResultsRevert(Object obj) {
        double[][] tem = (double[][]) ((MWNumericArray) obj).toDoubleArray();
        double[] result = new double[tem.length];
        for (int i = 0; i < tem.length; i++) {
            result[i] = tem[i][0];
        }
        return result;
    }

    public static double getSingleValue(Object obj) {
        return ((MWNumericArray) obj).getDouble();
    }

}
