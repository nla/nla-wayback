package au.gov.nla.wayback;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.archive.wayback.ResultURIConverter;
import org.archive.wayback.core.CaptureSearchResult;
import org.archive.wayback.core.CaptureSearchResults;
import org.archive.wayback.core.Resource;
import org.archive.wayback.core.WaybackRequest;
import org.archive.wayback.exception.SpecificCaptureReplayException;
import org.archive.wayback.replay.HttpHeaderProcessor;
import org.archive.wayback.replay.TransparentReplayRenderer; 

public class ForceDownloadReplayRenderer extends TransparentReplayRenderer {
	
    public ForceDownloadReplayRenderer(HttpHeaderProcessor httpHeaderProcessor) {
        super(httpHeaderProcessor);
    }

	@Override
	public void renderResource(HttpServletRequest httpRequest,
			HttpServletResponse httpResponse, WaybackRequest wbRequest,
			CaptureSearchResult result, Resource httpHeadersResource,
			Resource payloadResource, ResultURIConverter uriConverter,
			CaptureSearchResults results) throws ServletException, IOException,
			SpecificCaptureReplayException {
		httpResponse.addHeader("Content-Disposition", "attachment");
		super.renderResource(httpRequest, httpResponse, wbRequest, result,
				httpHeadersResource, payloadResource, uriConverter, results);
	}

}
